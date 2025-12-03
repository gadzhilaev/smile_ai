/// Утилиты для работы с текстом
class TextUtils {
  /// Очищает строку от некорректных UTF-16 символов
  /// Заменяет некорректные символы на пустую строку или безопасный символ
  static String sanitizeUtf16(String text) {
    if (text.isEmpty) return text;
    
    try {
      // Проверяем, является ли строка валидной UTF-16
      // Если строка содержит некорректные суррогатные пары, они будут заменены
      final buffer = StringBuffer();
      
      for (int i = 0; i < text.length; i++) {
        final codeUnit = text.codeUnitAt(i);
        
        // Проверяем, является ли это началом суррогатной пары (high surrogate)
        if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
          // Это high surrogate, проверяем следующий символ
          if (i + 1 < text.length) {
            final nextCodeUnit = text.codeUnitAt(i + 1);
            // Проверяем, является ли это low surrogate
            if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
              // Валидная суррогатная пара - сохраняем оба символа
              buffer.writeCharCode(codeUnit);
              buffer.writeCharCode(nextCodeUnit);
              i++; // Пропускаем следующий символ, так как он уже обработан
            } else {
              // Некорректная суррогатная пара - пропускаем high surrogate
              // Не добавляем ничего
            }
          } else {
            // Некорректная суррогатная пара в конце строки - пропускаем
            // Не добавляем ничего
          }
        } else if (codeUnit >= 0xDC00 && codeUnit <= 0xDFFF) {
          // Это low surrogate без high surrogate - пропускаем
          // Не добавляем ничего
        } else if (codeUnit == 0xFFFE || codeUnit == 0xFFFF) {
          // Специальные недопустимые символы - пропускаем
          // Не добавляем ничего
        } else {
          // Обычный валидный символ
          buffer.writeCharCode(codeUnit);
        }
      }
      
      return buffer.toString();
    } catch (e) {
      // В случае ошибки пытаемся восстановить строку, удаляя проблемные символы
      try {
        return text.replaceAll(RegExp(r'[\uFFFE\uFFFF]'), '');
      } catch (_) {
        // Если и это не помогло, возвращаем пустую строку
        return '';
      }
    }
  }
  
  /// Безопасно получает текст для отображения
  /// Очищает от некорректных UTF-16 символов перед использованием
  static String safeText(String? text) {
    if (text == null || text.isEmpty) return '';
    return sanitizeUtf16(text);
  }
}

