import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Утилита для работы с .env файлом
class EnvUtils {
  static Directory? _cachedSupportDir;

  static bool get _isMobileRuntime =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Создать .env файл с пустыми значениями, если его нет
  static Future<void> createEnvFileIfNotExists() async {
    try {
      final envPath = await _getEnvFilePath();
      final envFile = File(envPath);
      
      // Если файл уже существует, проверяем и при необходимости дописываем недостающие поля CONTEXT_*
      if (await envFile.exists()) {
        debugPrint('EnvUtils: .env file already exists, checking for CONTEXT_* keys');
        try {
          String content = await envFile.readAsString();
          final lines = content.split('\n');

          final List<String> requiredKeys = [
            'CONTEXT_USER_ROLE',
            'CONTEXT_BUSINESS_STAGE',
            'CONTEXT_GOAL',
            'CONTEXT_URGENCY',
            'CONTEXT_REGION',
            'CONTEXT_BUSINESS_NICHE',
          ];

          bool changed = false;

          for (final key in requiredKeys) {
            final exists = lines.any((line) => line.startsWith('$key='));
            if (!exists) {
              debugPrint('EnvUtils: $key not found in existing .env, adding empty value');
              if (content.isNotEmpty && !content.endsWith('\n')) {
                lines.add('');
              }
              lines.add('$key=');
              changed = true;
            }
          }

          if (changed) {
            final newContent = lines.join('\n');
            await envFile.writeAsString(newContent, flush: true);
            debugPrint('EnvUtils: .env file updated with missing CONTEXT_* keys');
          } else {
            debugPrint('EnvUtils: all CONTEXT_* keys already present');
          }
        } catch (e, stackTrace) {
          debugPrint('EnvUtils: error while upgrading existing .env: $e');
          debugPrint('EnvUtils: stack trace: $stackTrace');
        }
        return;
      }
      
      debugPrint('EnvUtils: .env file does not exist, creating with empty values');
      
      // Создаем содержимое файла с пустыми значениями
      final defaultContent = '''AUTH_TOKEN=
USER_ID=
USER_EMAIL=
USER_FULL_NAME=
USER_NICKNAME=
USER_PHONE=
USER_COUNTRY=
USER_GENDER=
CONTEXT_USER_ROLE=
CONTEXT_BUSINESS_STAGE=
CONTEXT_GOAL=
CONTEXT_URGENCY=
CONTEXT_REGION=
CONTEXT_BUSINESS_NICHE=
''';
      
      // Создаем родительские директории, если их нет
      final parentDir = envFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
        debugPrint('EnvUtils: created parent directory: ${parentDir.path}');
      }
      
      // Записываем файл
      await envFile.writeAsString(defaultContent, flush: true);
      debugPrint('EnvUtils: .env file created successfully at: $envPath');
      
      // Проверяем, что файл действительно создался
      if (await envFile.exists()) {
        debugPrint('EnvUtils: SUCCESS - .env file verified');
      } else {
        debugPrint('EnvUtils: ERROR - .env file does not exist after creation!');
        throw Exception('Failed to create .env file: file does not exist after write');
      }
    } catch (e, stackTrace) {
      debugPrint('EnvUtils: error creating .env file: $e');
      debugPrint('EnvUtils: error type: ${e.runtimeType}');
      debugPrint('EnvUtils: stack trace: $stackTrace');
      // Не пробрасываем ошибку дальше, так как это не критично
      // Приложение может работать и без .env файла
    }
  }

  /// Получить путь к .env файлу
  static Future<String> _getEnvFilePath() async {
    if (_isMobileRuntime) {
      final supportDir = await _getSupportDirectory();
      final envPath = path.join(supportDir.path, '.env');
      debugPrint('EnvUtils: using application support path: $envPath');
      return envPath;
    }
    return _findProjectEnvFilePath();
  }

  static Future<Directory> _getSupportDirectory() async {
    if (_cachedSupportDir != null) {
      return _cachedSupportDir!;
    }
    final dir = await getApplicationSupportDirectory();
    _cachedSupportDir = dir;
    return dir;
  }

  static Future<String> _findProjectEnvFilePath() async {
    try {
      final scriptPath = Platform.script.toFilePath();
      debugPrint('EnvUtils: Platform.script path: $scriptPath');

      var searchDir = path.dirname(scriptPath);
      debugPrint('EnvUtils: starting search from script dir: $searchDir');

      for (int i = 0; i < 15; i++) {
        final pubspecPath = path.join(searchDir, 'pubspec.yaml');
        final pubspecFile = File(pubspecPath);

        if (await pubspecFile.exists()) {
          final envPath = path.join(searchDir, '.env');
          debugPrint('EnvUtils: found project root at: $searchDir');
          debugPrint('EnvUtils: .env file path: $envPath');

          try {
            final testFile = File(path.join(searchDir, '.env_write_test'));
            await testFile.writeAsString('test');
            if (await testFile.exists()) {
              await testFile.delete();
              debugPrint('EnvUtils: write test successful');
              return envPath;
            }
          } catch (e) {
            debugPrint('EnvUtils: write test failed at $searchDir: $e');
          }
        }

        final parent = path.dirname(searchDir);
        if (parent == searchDir) {
          break;
        }
        searchDir = parent;
      }
    } catch (e) {
      debugPrint('EnvUtils: error using Platform.script: $e');
    }

    var searchDir = Directory.current.path;
    debugPrint('EnvUtils: trying current directory: $searchDir');

    for (int i = 0; i < 15; i++) {
      final pubspecPath = path.join(searchDir, 'pubspec.yaml');
      final pubspecFile = File(pubspecPath);

      if (await pubspecFile.exists()) {
        final envPath = path.join(searchDir, '.env');
        debugPrint('EnvUtils: found project root at: $searchDir');
        return envPath;
      }

      final parent = path.dirname(searchDir);
      if (parent == searchDir) {
        break;
      }
      searchDir = parent;
    }

    final knownPaths = [
      '/Users/admin/Documents/MobileProjects/smile_ai',
      path.join(Directory.current.path, '..', '..', '..'),
    ];

    for (final knownPath in knownPaths) {
      try {
        final normalizedPath = path.normalize(knownPath);
        final pubspecPath = path.join(normalizedPath, 'pubspec.yaml');
        if (await File(pubspecPath).exists()) {
          final envPath = path.join(normalizedPath, '.env');
          debugPrint('EnvUtils: using known path: $envPath');
          return envPath;
        }
      } catch (e) {
        // Продолжаем поиск
      }
    }

    final envPath = path.join(Directory.current.path, '.env');
    debugPrint('EnvUtils: WARNING - using fallback path: $envPath');
    return envPath;
  }

  /// Подмешиваем значения из доступного .env файла в уже загруженный dotenv
  static Future<void> mergeRuntimeEnvIntoDotenv() async {
    if (!dotenv.isInitialized) {
      debugPrint('EnvUtils: dotenv not initialized, merge skipped');
      return;
    }
    final overrides = await _readEnvFileAsMap();
    if (overrides.isEmpty) {
      return;
    }
    dotenv.env.addAll(overrides);
    debugPrint(
        'EnvUtils: merged runtime .env overrides: ${overrides.keys.join(", ")}');
  }

  static Future<Map<String, String>> _readEnvFileAsMap() async {
    try {
      final envPath = await _getEnvFilePath();
      final envFile = File(envPath);
      if (!await envFile.exists()) {
        return {};
      }
      final content = await envFile.readAsString();
      return _parseEnvContent(content);
    } catch (e) {
      debugPrint('EnvUtils: failed to read runtime .env: $e');
      return {};
    }
  }

  static Map<String, String> _parseEnvContent(String content) {
    final Map<String, String> result = {};
    final lines = content.split('\n');
    for (final rawLine in lines) {
      if (rawLine.trim().isEmpty || rawLine.trimLeft().startsWith('#')) {
        continue;
      }
      final index = rawLine.indexOf('=');
      if (index <= 0) continue;
      final key = rawLine.substring(0, index).trim();
      final value = rawLine.substring(index + 1).trim();
      if (key.isNotEmpty) {
        result[key] = value;
      }
    }
    return result;
  }

  static void _updateInMemoryEnv(String key, String value) {
    if (!dotenv.isInitialized) {
      debugPrint(
          'EnvUtils: dotenv not initialized, skipping in-memory update for $key');
      return;
    }
    dotenv.env[key] = value;
  }

  /// Обновить значение токена в .env файле
  static Future<void> updateTokenInEnv(String token) async {
    try {
      final envPath = await _getEnvFilePath();
      final envFile = File(envPath);
      
      String content = '';
      
      if (await envFile.exists()) {
        content = await envFile.readAsString();
        debugPrint('EnvUtils: .env file exists, current content length: ${content.length}');
      } else {
        debugPrint('EnvUtils: .env file does not exist, will create new one');
      }
      
      // Ищем строку с AUTH_TOKEN
      final lines = content.split('\n');
      bool tokenFound = false;
      
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('AUTH_TOKEN=')) {
          lines[i] = 'AUTH_TOKEN=$token';
          tokenFound = true;
          debugPrint('EnvUtils: found existing AUTH_TOKEN line, updating it');
          break;
        }
      }
      
      // Если токен не найден, добавляем новую строку
      if (!tokenFound) {
        debugPrint('EnvUtils: AUTH_TOKEN line not found, adding new one');
        if (content.isNotEmpty && !content.endsWith('\n')) {
          lines.add('');
        }
        lines.add('AUTH_TOKEN=$token');
      }
      
      // Записываем обратно в файл
      final newContent = lines.join('\n');
      debugPrint('EnvUtils: writing to file: $envPath');
      debugPrint('EnvUtils: new content preview: ${newContent.length} chars');
      
      // Создаем родительские директории, если их нет
      final parentDir = envFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
        debugPrint('EnvUtils: created parent directory: ${parentDir.path}');
      }
      
      // Записываем файл
      await envFile.writeAsString(newContent, flush: true);
      debugPrint('EnvUtils: file write completed');
      
      // Проверяем, что файл действительно записался
      if (await envFile.exists()) {
        final writtenContent = await envFile.readAsString();
        debugPrint('EnvUtils: file exists after write, content length: ${writtenContent.length}');
        
        // Проверяем, что токен действительно в файле
        if (writtenContent.contains('AUTH_TOKEN=$token')) {
          debugPrint('EnvUtils: SUCCESS - token verified in file');
          _updateInMemoryEnv('AUTH_TOKEN', token);
        } else {
          debugPrint('EnvUtils: WARNING - token not found in written file!');
          debugPrint('EnvUtils: written content: $writtenContent');
        }
      } else {
        debugPrint('EnvUtils: ERROR - file does not exist after write!');
        throw Exception('Failed to write .env file: file does not exist after write');
      }
    } catch (e, stackTrace) {
      debugPrint('EnvUtils: error updating token in .env: $e');
      debugPrint('EnvUtils: error type: ${e.runtimeType}');
      debugPrint('EnvUtils: stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Обновить данные пользователя в .env файле (кроме пароля)
  static Future<void> updateUserDataInEnv({
    required String email,
    required String fullName,
    required String nickname,
    required String phone,
    required String country,
    required String gender,
  }) async {
    try {
      final envPath = await _getEnvFilePath();
      final envFile = File(envPath);
      
      String content = '';
      
      if (await envFile.exists()) {
        content = await envFile.readAsString();
        debugPrint('EnvUtils: .env file exists, current content length: ${content.length}');
      } else {
        debugPrint('EnvUtils: .env file does not exist, will create new one');
      }
      
      // Ищем существующие строки с данными пользователя
      final lines = content.split('\n');
      final Map<String, String> userData = {
        'USER_EMAIL': email,
        'USER_FULL_NAME': fullName,
        'USER_NICKNAME': nickname,
        'USER_PHONE': phone,
        'USER_COUNTRY': country,
        'USER_GENDER': gender,
      };
      
      // Обновляем или добавляем каждое поле
      for (final entry in userData.entries) {
        bool found = false;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('${entry.key}=')) {
            lines[i] = '${entry.key}=${entry.value}';
            found = true;
            debugPrint('EnvUtils: found existing ${entry.key} line, updating it');
            break;
          }
        }
        
        if (!found) {
          debugPrint('EnvUtils: ${entry.key} line not found, adding new one');
          if (content.isNotEmpty && !content.endsWith('\n')) {
            lines.add('');
          }
          lines.add('${entry.key}=${entry.value}');
        }
      }
      
      // Записываем обратно в файл
      final newContent = lines.join('\n');
      debugPrint('EnvUtils: writing user data to file: $envPath');
      
      // Создаем родительские директории, если их нет
      final parentDir = envFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
        debugPrint('EnvUtils: created parent directory: ${parentDir.path}');
      }
      
      // Записываем файл
      await envFile.writeAsString(newContent, flush: true);
      debugPrint('EnvUtils: user data write completed');
      
      // Проверяем, что файл действительно записался
      if (await envFile.exists()) {
        final writtenContent = await envFile.readAsString();
        debugPrint('EnvUtils: file exists after write, content length: ${writtenContent.length}');
        
        // Проверяем, что данные действительно в файле
        bool allDataFound = true;
        for (final entry in userData.entries) {
          if (!writtenContent.contains('${entry.key}=${entry.value}')) {
            allDataFound = false;
            debugPrint('EnvUtils: WARNING - ${entry.key} not found in written file!');
          }
        }
        
        if (allDataFound) {
          debugPrint('EnvUtils: SUCCESS - all user data verified in file');
          for (final entry in userData.entries) {
            _updateInMemoryEnv(entry.key, entry.value);
          }
        }
      } else {
        debugPrint('EnvUtils: ERROR - file does not exist after write!');
        throw Exception('Failed to write .env file: file does not exist after write');
      }
    } catch (e, stackTrace) {
      debugPrint('EnvUtils: error updating user data in .env: $e');
      debugPrint('EnvUtils: error type: ${e.runtimeType}');
      debugPrint('EnvUtils: stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Обновить user_id в .env файле
  static Future<void> updateUserIdInEnv(String userId) async {
    try {
      final envPath = await _getEnvFilePath();
      final envFile = File(envPath);
      
      String content = '';
      
      if (await envFile.exists()) {
        content = await envFile.readAsString();
        debugPrint('EnvUtils: .env file exists, current content length: ${content.length}');
      } else {
        debugPrint('EnvUtils: .env file does not exist, will create new one');
      }
      
      // Ищем строку с USER_ID
      final lines = content.split('\n');
      bool userIdFound = false;
      
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('USER_ID=')) {
          lines[i] = 'USER_ID=$userId';
          userIdFound = true;
          debugPrint('EnvUtils: found existing USER_ID line, updating it');
          break;
        }
      }
      
      // Если user_id не найден, добавляем новую строку
      if (!userIdFound) {
        debugPrint('EnvUtils: USER_ID line not found, adding new one');
        if (content.isNotEmpty && !content.endsWith('\n')) {
          lines.add('');
        }
        lines.add('USER_ID=$userId');
      }
      
      // Записываем обратно в файл
      final newContent = lines.join('\n');
      debugPrint('EnvUtils: writing USER_ID to file: $envPath');
      
      // Создаем родительские директории, если их нет
      final parentDir = envFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
        debugPrint('EnvUtils: created parent directory: ${parentDir.path}');
      }
      
      // Записываем файл
      await envFile.writeAsString(newContent, flush: true);
      debugPrint('EnvUtils: USER_ID write completed');
      
      // Проверяем, что файл действительно записался
      if (await envFile.exists()) {
        final writtenContent = await envFile.readAsString();
        debugPrint('EnvUtils: file exists after write, content length: ${writtenContent.length}');
        
        // Проверяем, что user_id действительно в файле
        if (writtenContent.contains('USER_ID=$userId')) {
          debugPrint('EnvUtils: SUCCESS - USER_ID verified in file');
          _updateInMemoryEnv('USER_ID', userId);
        } else {
          debugPrint('EnvUtils: WARNING - USER_ID not found in written file!');
          debugPrint('EnvUtils: written content: $writtenContent');
        }
      } else {
        debugPrint('EnvUtils: ERROR - file does not exist after write!');
        throw Exception('Failed to write .env file: file does not exist after write');
      }
    } catch (e, stackTrace) {
      debugPrint('EnvUtils: error updating USER_ID in .env: $e');
      debugPrint('EnvUtils: error type: ${e.runtimeType}');
      debugPrint('EnvUtils: stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Очистить .env файл (сделать все переменные пустыми)
  static Future<void> clearEnvFile() async {
    try {
      final envPath = await _getEnvFilePath();
      final envFile = File(envPath);
      
      // Создаем содержимое файла с пустыми значениями
      final emptyContent = '''AUTH_TOKEN=
USER_ID=
USER_EMAIL=
USER_FULL_NAME=
USER_NICKNAME=
USER_PHONE=
USER_COUNTRY=
USER_GENDER=
CONTEXT_USER_ROLE=
CONTEXT_BUSINESS_STAGE=
CONTEXT_GOAL=
CONTEXT_URGENCY=
CONTEXT_REGION=
CONTEXT_BUSINESS_NICHE=
''';
      
      // Создаем родительские директории, если их нет
      final parentDir = envFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
        debugPrint('EnvUtils: created parent directory: ${parentDir.path}');
      }
      
      // Записываем файл с пустыми значениями
      await envFile.writeAsString(emptyContent, flush: true);
      debugPrint('EnvUtils: .env file cleared successfully');
      
      // Очищаем in-memory значения
      if (dotenv.isInitialized) {
        dotenv.env['AUTH_TOKEN'] = '';
        dotenv.env['USER_ID'] = '';
        dotenv.env['USER_EMAIL'] = '';
        dotenv.env['USER_FULL_NAME'] = '';
        dotenv.env['USER_NICKNAME'] = '';
        dotenv.env['USER_PHONE'] = '';
        dotenv.env['USER_COUNTRY'] = '';
        dotenv.env['USER_GENDER'] = '';
        dotenv.env['CONTEXT_USER_ROLE'] = '';
        dotenv.env['CONTEXT_BUSINESS_STAGE'] = '';
        dotenv.env['CONTEXT_GOAL'] = '';
        dotenv.env['CONTEXT_URGENCY'] = '';
        dotenv.env['CONTEXT_REGION'] = '';
        dotenv.env['CONTEXT_BUSINESS_NICHE'] = '';
        debugPrint('EnvUtils: in-memory .env values cleared');
      }
    } catch (e, stackTrace) {
      debugPrint('EnvUtils: error clearing .env file: $e');
      debugPrint('EnvUtils: error type: ${e.runtimeType}');
      debugPrint('EnvUtils: stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Сохранить контекст беседы в .env файл
  static Future<void> saveConversationContext(Map<String, String>? context) async {
    try {
      final envPath = await _getEnvFilePath();
      final envFile = File(envPath);
      
      String content = '';
      
      if (await envFile.exists()) {
        content = await envFile.readAsString();
        debugPrint('EnvUtils: .env file exists, current content length: ${content.length}');
      } else {
        debugPrint('EnvUtils: .env file does not exist, will create new one');
      }
      
      // Ищем существующие строки с контекстом
      final lines = content.split('\n');
      final Map<String, String> contextKeys = {
        'CONTEXT_USER_ROLE': context?['user_role'] ?? '',
        'CONTEXT_BUSINESS_STAGE': context?['business_stage'] ?? '',
        'CONTEXT_GOAL': context?['goal'] ?? '',
        'CONTEXT_URGENCY': context?['urgency'] ?? '',
        'CONTEXT_REGION': context?['region'] ?? '',
        'CONTEXT_BUSINESS_NICHE': context?['business_niche'] ?? '',
      };
      
      // Обновляем или добавляем каждое поле
      for (final entry in contextKeys.entries) {
        bool found = false;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('${entry.key}=')) {
            lines[i] = '${entry.key}=${entry.value}';
            found = true;
            debugPrint('EnvUtils: found existing ${entry.key} line, updating it');
            break;
          }
        }
        
        if (!found) {
          debugPrint('EnvUtils: ${entry.key} line not found, adding new one');
          if (content.isNotEmpty && !content.endsWith('\n')) {
            lines.add('');
          }
          lines.add('${entry.key}=${entry.value}');
        }
      }
      
      // Записываем обратно в файл
      final newContent = lines.join('\n');
      debugPrint('EnvUtils: writing conversation context to file: $envPath');
      
      // Создаем родительские директории, если их нет
      final parentDir = envFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
        debugPrint('EnvUtils: created parent directory: ${parentDir.path}');
      }
      
      // Записываем файл
      await envFile.writeAsString(newContent, flush: true);
      debugPrint('EnvUtils: conversation context write completed');
      
      // Обновляем в памяти
      for (final entry in contextKeys.entries) {
        _updateInMemoryEnv(entry.key, entry.value);
      }
    } catch (e, stackTrace) {
      debugPrint('EnvUtils: error saving conversation context in .env: $e');
      debugPrint('EnvUtils: error type: ${e.runtimeType}');
      debugPrint('EnvUtils: stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Загрузить контекст беседы из .env файла
  static Map<String, String>? loadConversationContext() {
    try {
      if (!dotenv.isInitialized) {
        debugPrint('EnvUtils: dotenv not initialized, cannot load context');
        return null;
      }
      
      final Map<String, String> context = {};
      
      final userRole = dotenv.env['CONTEXT_USER_ROLE']?.trim();
      if (userRole != null && userRole.isNotEmpty) {
        context['user_role'] = userRole;
      }
      
      final businessStage = dotenv.env['CONTEXT_BUSINESS_STAGE']?.trim();
      if (businessStage != null && businessStage.isNotEmpty) {
        context['business_stage'] = businessStage;
      }
      
      final goal = dotenv.env['CONTEXT_GOAL']?.trim();
      if (goal != null && goal.isNotEmpty) {
        context['goal'] = goal;
      }
      
      final urgency = dotenv.env['CONTEXT_URGENCY']?.trim();
      if (urgency != null && urgency.isNotEmpty) {
        context['urgency'] = urgency;
      }
      
      final region = dotenv.env['CONTEXT_REGION']?.trim();
      if (region != null && region.isNotEmpty) {
        context['region'] = region;
      }
      
      final businessNiche = dotenv.env['CONTEXT_BUSINESS_NICHE']?.trim();
      if (businessNiche != null && businessNiche.isNotEmpty) {
        context['business_niche'] = businessNiche;
      }
      
      return context.isNotEmpty ? context : null;
    } catch (e) {
      debugPrint('EnvUtils: error loading conversation context from .env: $e');
      return null;
    }
  }
}

