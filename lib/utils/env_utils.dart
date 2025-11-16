import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Утилита для работы с .env файлом
class EnvUtils {
  /// Получить путь к .env файлу в корне проекта
  static Future<String> _getEnvFilePath() async {
    // На мобильных устройствах нужно найти корень проекта
    // Пробуем несколько способов
    
    // Способ 1: Используем Platform.script для определения пути к приложению
    try {
      final scriptPath = Platform.script.toFilePath();
      debugPrint('EnvUtils: Platform.script path: $scriptPath');
      
      // Получаем директорию, где находится скрипт
      var searchDir = path.dirname(scriptPath);
      debugPrint('EnvUtils: starting search from script dir: $searchDir');
      
      // Поднимаемся вверх, ища pubspec.yaml (максимум 15 уровней)
      for (int i = 0; i < 15; i++) {
        final pubspecPath = path.join(searchDir, 'pubspec.yaml');
        final pubspecFile = File(pubspecPath);
        
        if (await pubspecFile.exists()) {
          // Нашли корень проекта
          final envPath = path.join(searchDir, '.env');
          debugPrint('EnvUtils: found project root at: $searchDir');
          debugPrint('EnvUtils: .env file path: $envPath');
          
          // Проверяем, можем ли мы записать
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
        
        // Поднимаемся на уровень вверх
        final parent = path.dirname(searchDir);
        if (parent == searchDir) {
          break;
        }
        searchDir = parent;
      }
    } catch (e) {
      debugPrint('EnvUtils: error using Platform.script: $e');
    }
    
    // Способ 2: Ищем от текущей директории
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
    
    // Способ 3: Используем известный путь к проекту (для разработки)
    // Пробуем путь, где обычно находится проект при запуске через flutter run
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
    
    // Fallback: используем текущую директорию
    final envPath = path.join(Directory.current.path, '.env');
    debugPrint('EnvUtils: WARNING - using fallback path: $envPath');
    return envPath;
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
}

