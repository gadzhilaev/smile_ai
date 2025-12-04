import 'package:flutter/material.dart';
import '../utils/text_utils.dart';

/// Виджет для отображения текста с переносами по слогам и дефисами
class SyllableText extends StatelessWidget {
  const SyllableText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
    this.maxLines = 3,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    // Разбиваем текст на слова
    final words = text.split(' ');
    final List<TextSpan> spans = [];
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final syllables = TextUtils.splitIntoSyllables(word);
      
      if (syllables.length <= 1) {
        // Слово из одного слога - добавляем как есть
        spans.add(TextSpan(text: word, style: style));
      } else {
        // Слово из нескольких слогов - добавляем мягкие переносы между слогами
        // Используем мягкий перенос (\u00AD) перед каждым слогом, кроме первого
        // Flutter автоматически покажет дефис при переносе строки
        for (int j = 0; j < syllables.length; j++) {
          final syllable = syllables[j];
          if (j == 0) {
            spans.add(TextSpan(text: syllable, style: style));
          } else {
            // Добавляем мягкий перенос перед слогом
            // Мягкий перенос позволяет Flutter переносить текст по слогам
            // Дефис будет показан автоматически при переносе
            spans.add(TextSpan(text: '\u00AD$syllable', style: style));
          }
        }
      }
      
      // Добавляем пробел между словами (кроме последнего)
      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: style));
      }
    }
    
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

