import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/profile_service.dart';
import '../services/support_service.dart';
import '../services/fcm_service.dart';
import '../services/websocket_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  static const double _designWidth = 428;
  static const double _designHeight = 926;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<_SupportMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _attachedImages = [];
  bool _isLoading = false;
  bool _isSending = false;
  Timer? _pollingTimer; // Fallback на случай если WebSocket недоступен
  DateTime? _lastMessageTime;

  @override
  void initState() {
    super.initState();
    _loadMessageHistory();
    
    // Подключаемся к WebSocket для обновлений в реальном времени
    final userId = _getUserId();
    if (userId != null && userId.isNotEmpty) {
      WebSocketService.connectToChat(userId);
      
      // Подписываемся на новые сообщения через WebSocket
      WebSocketService.onNewMessage = (data) {
        if (mounted && data['user_id'] == userId) {
          _handleNewMessageFromWebSocket(data);
        }
      };
    }
    
    // Fallback: запускаем polling только если WebSocket не подключен
    _startPollingFallback();
    
    // Подписываемся на обновления истории при получении push уведомлений
    FCMService.onSupportReplyReceived = _loadMessageHistory;
  }
  
  /// Обработка нового сообщения из WebSocket
  void _handleNewMessageFromWebSocket(Map<String, dynamic> data) {
    if (!mounted) return;
    
    try {
      // Парсим данные сообщения
      final messageText = data['message'] ?? '';
      final isFromSupport = data['direction'] == 'support' || data['from_support'] == true;
      
      // Парсим изображения
      List<String>? imagePaths;
      if (data['photo_url'] != null) {
        final photoUrl = data['photo_url'].toString();
        if (photoUrl.isNotEmpty && !photoUrl.startsWith('[')) {
          imagePaths = [photoUrl];
        }
      }
      if (data['photo_urls'] != null) {
        final parsed = parseImageUrls(data['photo_urls']);
        if (parsed.isNotEmpty) {
          imagePaths = parsed;
        }
      }
      
      // Парсим дату
      DateTime? createdAt;
      if (data['created_at'] != null) {
        try {
          createdAt = DateTime.parse(data['created_at'].toString());
        } catch (e) {
          // Ошибка парсинга даты
        }
      }
      createdAt ??= DateTime.now();
      
      // Проверяем, нет ли локального сообщения с таким же содержимым (чтобы заменить его)
      bool foundLocalMessage = false;
      for (int i = 0; i < _messages.length; i++) {
        final existingMsg = _messages[i];
        // Если это локальное сообщение пользователя с таким же текстом и изображениями
        if (existingMsg.tempId != null &&
            !existingMsg.fromSupport &&
            existingMsg.text == messageText &&
            existingMsg.createdAt != null &&
            existingMsg.createdAt!.difference(createdAt).abs().inSeconds < 10) {
          // Проверяем изображения
          bool imagesMatch = true;
          if (imagePaths != null && imagePaths.isNotEmpty) {
            final localImages = existingMsg.imagePaths ?? [];
            if (localImages.length != imagePaths.length) {
              imagesMatch = false;
            }
          } else if (existingMsg.imagePaths != null && existingMsg.imagePaths!.isNotEmpty) {
            imagesMatch = false;
          }
          
          if (imagesMatch) {
            // Заменяем локальное сообщение на сообщение с сервера (убираем tempId)
            setState(() {
              _messages[i] = _SupportMessage(
                fromSupport: isFromSupport,
                text: messageText,
                imagePaths: imagePaths,
                isLocalFiles: false,
                createdAt: createdAt,
                tempId: null, // Убираем tempId, чтобы сообщение не считалось локальным
              );
            });
            foundLocalMessage = true;
            break;
          }
        }
      }
      
      // Если не нашли локальное сообщение для замены, проверяем на дубликаты
      // (сообщения от поддержки или уже сохраненные сообщения)
      if (!foundLocalMessage) {
        bool isDuplicate = false;
        for (final existingMsg in _messages) {
          // Проверяем на дубликаты: одинаковый текст, от того же отправителя, в пределах 5 секунд
          if (existingMsg.text == messageText &&
              existingMsg.fromSupport == isFromSupport &&
              existingMsg.createdAt != null &&
              existingMsg.createdAt!.difference(createdAt).abs().inSeconds < 5) {
            // Проверяем изображения
            bool imagesMatch = true;
            final existingImages = existingMsg.imagePaths ?? [];
            final newImages = imagePaths ?? [];
            if (existingImages.length != newImages.length) {
              imagesMatch = false;
            } else if (existingImages.isNotEmpty && newImages.isNotEmpty) {
              // Сравниваем URL изображений
              for (int j = 0; j < existingImages.length; j++) {
                if (existingImages[j] != newImages[j]) {
                  imagesMatch = false;
                  break;
                }
              }
            }
            
            if (imagesMatch) {
              isDuplicate = true;
              break;
            }
          }
        }
        
        if (!isDuplicate) {
          setState(() {
            _messages.add(
              _SupportMessage(
                fromSupport: isFromSupport,
                text: messageText,
                imagePaths: imagePaths,
                isLocalFiles: false,
                createdAt: createdAt,
                tempId: null, // Сообщение с сервера не имеет tempId
              ),
            );
          });
          _scrollToBottom();
        }
      } else {
        _scrollToBottom();
      }
      
      _lastMessageTime = createdAt;
    } catch (e) {
      // Ошибка обработки сообщения из WebSocket
    }
  }
  
  /// Парсинг URL изображений
  List<String> parseImageUrls(dynamic value) {
    if (value == null) return [];
    
    if (value is List) {
      return List<String>.from(value.map((url) => url.toString()));
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = json.decode(trimmed) as List<dynamic>;
          return List<String>.from(decoded.map((url) => url.toString()));
        } catch (e) {
          return [];
        }
      } else {
        return [trimmed];
      }
    }
    
    return [];
  }

  /// Запуск polling как fallback (только если WebSocket не подключен)
  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        // Используем polling только если WebSocket не подключен
        if (!WebSocketService.isConnected) {
          _checkForNewMessages();
        }
      }
    });
  }

  /// Проверка новых сообщений
  Future<void> _checkForNewMessages() async {
    final userId = _getUserId();
    if (userId == null || userId.isEmpty) return;

    try {
      // Передаем user_name для приветственного сообщения
    final fullName = ProfileService.instance.fullName;
      final history = await SupportService.getMessageHistory(
        userId,
        userName: fullName.isNotEmpty ? fullName : null,
      );
      if (!mounted) return;

      // Находим последнее сообщение по времени
      DateTime? latestTime;
      for (final msg in history) {
        DateTime? msgTime;
        if (msg['created_at'] != null) {
          try {
            msgTime = DateTime.parse(msg['created_at'].toString());
          } catch (e) {
            // Игнорируем ошибки парсинга
          }
        } else if (msg['timestamp'] != null) {
          try {
            final timestamp = msg['timestamp'];
            if (timestamp is int) {
              msgTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
            } else if (timestamp is String) {
              msgTime = DateTime.parse(timestamp);
            }
          } catch (e) {
            // Игнорируем ошибки парсинга
          }
        }
        
        if (msgTime != null && (latestTime == null || msgTime.isAfter(latestTime))) {
          latestTime = msgTime;
        }
      }

      // Если есть новые сообщения (после последнего известного времени)
      if (latestTime != null && 
          (_lastMessageTime == null || latestTime.isAfter(_lastMessageTime!))) {
        // Перезагружаем историю
        await _loadMessageHistory();
        _lastMessageTime = latestTime;
      }
    } catch (e) {
      // Ошибка проверки новых сообщений
    }
  }

  Future<void> _loadMessageHistory() async {
    final userId = _getUserId();
    
      setState(() {
      _isLoading = true;
    });

    // Если USER_ID не найден, показываем пустой список сообщений
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        setState(() {
          _messages.clear();
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // Передаем user_name только для GET запроса истории (не для отправки сообщений)
      final fullName = ProfileService.instance.fullName;
      final history = await SupportService.getMessageHistory(
        userId,
        userName: fullName.isNotEmpty ? fullName : null,
      );
      if (mounted) {
        setState(() {
          // НЕ очищаем список полностью, чтобы не потерять сообщения, добавленные через WebSocket
          // Вместо этого добавляем только новые сообщения из истории
          // Создаем временный список для новых сообщений из истории
          final newMessagesFromHistory = <_SupportMessage>[];
          
          for (final msg in history) {
            List<String>? imagePaths;
            
            // Функция для безопасного парсинга строки как JSON-массива или обычной строки
            List<String> parseImageUrls(dynamic value) {
              if (value == null) return [];
              
              if (value is List) {
                // Если это уже массив
                return List<String>.from(value.map((url) => url.toString()));
              } else if (value is String) {
                // Проверяем, является ли строка JSON-массивом
                final trimmed = value.trim();
                if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
                  // Это похоже на JSON-массив, пытаемся распарсить
                  try {
                    final decoded = json.decode(trimmed) as List<dynamic>;
                    return List<String>.from(decoded.map((url) => url.toString()));
                  } catch (e) {
                    // Ошибка парсинга JSON-массива
                    // Если не удалось распарсить, возвращаем пустой список
                    return [];
                  }
                } else {
                  // Обычная строка - одно фото
                  return [trimmed];
                }
              }
              
              return [];
            }
            
            // Обрабатываем photo_url (одно фото)
            if (msg['photo_url'] != null) {
              final parsed = parseImageUrls(msg['photo_url']);
              if (parsed.isNotEmpty) {
                imagePaths = parsed;
              }
            }
            
            // Обрабатываем photo_urls (несколько фото) - имеет приоритет над photo_url
            if (msg['photo_urls'] != null) {
              final parsed = parseImageUrls(msg['photo_urls']);
              if (parsed.isNotEmpty) {
                imagePaths = parsed;
              }
            }
            
            // Убеждаемся, что imagePath не является строкой JSON-массива
            String? singleImagePath;
            if (imagePaths != null && imagePaths.isNotEmpty) {
              final firstPath = imagePaths.first.trim();
              // Проверяем, что это не JSON-массив
              if (!firstPath.startsWith('[') || !firstPath.endsWith(']')) {
                singleImagePath = firstPath;
              }
            }
            
            // Парсим дату создания сообщения
            DateTime? createdAt;
            if (msg['created_at'] != null) {
              try {
                final dateStr = msg['created_at'].toString();
                createdAt = DateTime.parse(dateStr);
              } catch (e) {
                // Ошибка парсинга даты
              }
            } else if (msg['timestamp'] != null) {
              try {
                final timestamp = msg['timestamp'];
                if (timestamp is int) {
                  createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                } else if (timestamp is String) {
                  createdAt = DateTime.parse(timestamp);
                }
              } catch (e) {
                // Ошибка парсинга timestamp
              }
            }
            // Если дата не найдена, используем текущую дату
            createdAt ??= DateTime.now();
            
            final messageText = msg['message'] ?? '';
            final isFromSupport = msg['direction'] == 'support' || msg['from_support'] == true;
            
            // Проверяем, нет ли локального сообщения для замены
            bool foundLocalMessage = false;
            for (int i = 0; i < _messages.length; i++) {
              final existingMsg = _messages[i];
              if (existingMsg.tempId != null &&
                  !existingMsg.fromSupport &&
                  existingMsg.text == messageText &&
                  existingMsg.createdAt != null &&
                  existingMsg.createdAt!.difference(createdAt).abs().inSeconds < 10) {
                // Проверяем изображения
                bool imagesMatch = true;
                if (imagePaths != null && imagePaths.isNotEmpty) {
                  final localImages = existingMsg.imagePaths ?? [];
                  if (localImages.length != imagePaths.length) {
                    imagesMatch = false;
                  }
                } else if (existingMsg.imagePaths != null && existingMsg.imagePaths!.isNotEmpty) {
                  imagesMatch = false;
                }
                
                if (imagesMatch) {
                  // Заменяем локальное сообщение на сообщение из истории
                  _messages[i] = _SupportMessage(
                    fromSupport: isFromSupport,
                    text: messageText,
                    imagePath: singleImagePath,
                    imagePaths: imagePaths,
                    isLocalFiles: false,
                    createdAt: createdAt,
                    tempId: null, // Убираем tempId, чтобы сообщение не считалось локальным
                  );
                  foundLocalMessage = true;
                  break;
                }
              }
            }
            
            // Если не нашли локальное сообщение, проверяем на дубликаты
            // Проверяем все сообщения, включая те, что были добавлены через WebSocket
            if (!foundLocalMessage) {
              bool isDuplicate = false;
              for (final existingMsg in _messages) {
                // Проверяем на дубликаты: одинаковый текст, от того же отправителя, в пределах 5 секунд
                if (existingMsg.text == messageText &&
                    existingMsg.fromSupport == isFromSupport &&
                    existingMsg.createdAt != null &&
                    existingMsg.createdAt!.difference(createdAt).abs().inSeconds < 5) {
                  // Проверяем изображения
                  bool imagesMatch = true;
                  final existingImages = existingMsg.imagePaths ?? [];
                  final newImages = imagePaths ?? [];
                  if (existingImages.length != newImages.length) {
                    imagesMatch = false;
                  } else if (existingImages.isNotEmpty && newImages.isNotEmpty) {
                    // Сравниваем URL изображений
                    for (int j = 0; j < existingImages.length; j++) {
                      if (existingImages[j] != newImages[j]) {
                        imagesMatch = false;
                        break;
                      }
                    }
                  }
                  
                  if (imagesMatch) {
                    isDuplicate = true;
                    break;
                  }
                }
              }
              
              if (!isDuplicate) {
                newMessagesFromHistory.add(
                  _SupportMessage(
                    fromSupport: isFromSupport,
                    text: messageText,
                    imagePath: singleImagePath,
                    imagePaths: imagePaths,
                    isLocalFiles: false, // Из истории - это URL, не локальные файлы
                    createdAt: createdAt,
                    tempId: null, // Сообщение из истории не имеет tempId
                  ),
                );
              }
            }
          }
          
          // Теперь добавляем новые сообщения из истории в основной список
          // Проверяем каждое сообщение на дубликаты с уже существующими сообщениями
          for (final newMsg in newMessagesFromHistory) {
            bool isDuplicate = false;
            for (final existingMsg in _messages) {
              // Проверяем на дубликаты: одинаковый текст, от того же отправителя, в пределах 5 секунд
              if (existingMsg.text == newMsg.text &&
                  existingMsg.fromSupport == newMsg.fromSupport &&
                  existingMsg.createdAt != null &&
                  newMsg.createdAt != null &&
                  existingMsg.createdAt!.difference(newMsg.createdAt!).abs().inSeconds < 5) {
                // Проверяем изображения
                bool imagesMatch = true;
                final existingImages = existingMsg.imagePaths ?? [];
                final newImages = newMsg.imagePaths ?? [];
                if (existingImages.length != newImages.length) {
                  imagesMatch = false;
                } else if (existingImages.isNotEmpty && newImages.isNotEmpty) {
                  // Сравниваем URL изображений
                  for (int j = 0; j < existingImages.length; j++) {
                    if (existingImages[j] != newImages[j]) {
                      imagesMatch = false;
                      break;
                    }
                  }
                }
                
                if (imagesMatch) {
                  isDuplicate = true;
                  break;
                }
              }
            }
            
            if (!isDuplicate) {
              _messages.add(newMsg);
            }
          }
          
          // Сортируем сообщения по времени создания
          _messages.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return a.createdAt!.compareTo(b.createdAt!);
          });
          
          // Обновляем время последнего сообщения
          if (_messages.isNotEmpty) {
            final lastMessage = _messages.last;
            if (lastMessage.createdAt != null) {
              _lastMessageTime = lastMessage.createdAt;
            }
          }
          
          _isLoading = false;
      });
      _scrollToBottom();
      }
    } catch (e) {
      // Ошибка загрузки истории
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // При ошибке показываем пустой список сообщений
      }
    }
  }

  String? _getUserId() {
    try {
      return dotenv.env['USER_ID'];
    } catch (e) {
      // Ошибка получения USER_ID
      return null;
    }
  }

  String _formatDate(DateTime date) {
    // Форматируем дату в формате "16 ноября"
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
  
  bool _shouldShowDate(int index) {
    if (index == 0) return true; // Всегда показываем дату для первого сообщения
    
    if (index >= _messages.length) return false;
    
    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];
    
    if (currentMessage.createdAt == null || previousMessage.createdAt == null) {
      return false;
    }
    
    // Показываем дату, если она отличается от предыдущего сообщения
    final currentDate = DateTime(
      currentMessage.createdAt!.year,
      currentMessage.createdAt!.month,
      currentMessage.createdAt!.day,
    );
    final previousDate = DateTime(
      previousMessage.createdAt!.year,
      previousMessage.createdAt!.month,
      previousMessage.createdAt!.day,
    );
    
    return !currentDate.isAtSameMomentAs(previousDate);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickImage() async {
    try {
      // Проверяем, сколько еще можно добавить
      final remainingSlots = 10 - _attachedImages.length;
      if (remainingSlots <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Можно выбрать максимум 10 фотографий')),
          );
        }
        return;
      }

      // Выбираем изображения (ограничение будет применено после выбора)
      final files = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (files.isEmpty) return;
      
      // Дополнительная проверка (на случай если pickMultiImage не поддерживает limit)
      final filesToAdd = files.take(remainingSlots).toList();
      
      setState(() {
        _attachedImages.addAll(filesToAdd);
      });
      
      // Если выбрано больше, чем можно добавить, показываем сообщение
      if (files.length > remainingSlots && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Добавлено только $remainingSlots из ${files.length} фотографий (максимум 10)')),
        );
      }
    } catch (e) {
      // Ошибка выбора изображения
    }
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  bool _isNetworkUrl(String path) {
    // Если путь выглядит как JSON-массив, это не валидный путь
    final trimmed = path.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      return false;
    }
    return path.startsWith('http://') || 
           path.startsWith('https://') || 
           path.startsWith('/');
  }

  String _getImageUrl(String path) {
    if (_isNetworkUrl(path)) {
      // Если путь начинается с /, добавляем baseUrl
      if (path.startsWith('/')) {
        return '${SupportService.baseUrl}$path';
      }
      // Если уже полный URL, возвращаем как есть
      return path;
    }
    // Локальный файл
    return path;
  }

  void _openImageFullScreen(String path) {
    // Проверяем, что путь валидный (не JSON-массив)
    final trimmed = path.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      // Попытка открыть невалидный путь
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: невалидный путь к изображению')),
        );
      }
      return;
    }
    
    final imageUrl = _getImageUrl(path);
    final isNetwork = _isNetworkUrl(path);
    
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: InteractiveViewer(
              child: isNetwork
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Ошибка загрузки изображения'),
                        );
                      },
                    )
                  : Image.file(
                File(path),
                fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('Ошибка загрузки изображения'),
                        );
                      },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty && _attachedImages.isEmpty) return;

    final userId = _getUserId();
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: пользователь не авторизован')),
        );
      }
      return;
    }

    setState(() {
      _isSending = true;
    });

    // Сохраняем данные перед отправкой
    final messageText = text;
    final imagesToSend = List<XFile>.from(_attachedImages);
    
    // Генерируем временный ID для локального сообщения
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Добавляем сообщение в UI сразу для лучшего UX
    // Помечаем как локальные файлы, чтобы показывать их локально
    setState(() {
      _messages.add(
        _SupportMessage(
          fromSupport: false,
          text: messageText,
          imagePaths: imagesToSend.map((img) => img.path).toList(),
          isLocalFiles: true, // Это локальные файлы, показываем их локально
          createdAt: DateTime.now(),
          tempId: tempId, // Временный ID для отслеживания
        ),
      );
      _inputController.clear();
      _attachedImages.clear();
    });
    _scrollToBottom();

    try {
      // Преобразуем XFile в File и проверяем существование
      List<File>? photoFiles;
      if (imagesToSend.isNotEmpty) {
        photoFiles = [];
        for (final xFile in imagesToSend) {
          final file = File(xFile.path);
          if (!await file.exists()) {
            throw Exception('Файл изображения не найден: ${xFile.path}');
          }
          photoFiles.add(file);
        }
      }
      
      // Отправляем все фото одним запросом
      await SupportService.sendMessage(
        userId: userId,
        userName: ProfileService.instance.fullName.isNotEmpty
            ? ProfileService.instance.fullName
            : null,
        message: messageText,
        photos: photoFiles, // Отправляем все фото одним запросом
      );
      
      // После успешной отправки НЕ перезагружаем историю сразу
      // Сообщение уже добавлено локально, оно будет заменено при получении с сервера через WebSocket
      // НЕ вызываем _loadMessageHistory() здесь, чтобы избежать дублирования
    } catch (e) {
      if (mounted) {
        // Удаляем локальное сообщение из списка при ошибке
        setState(() {
          _messages.removeWhere((msg) => msg.tempId == tempId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Отключаемся от WebSocket
    WebSocketService.disconnect();
    WebSocketService.onNewMessage = null;
    
    // Отписываемся от обновлений
    FCMService.onSupportReplyReceived = null;
    _pollingTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / SupportScreen._designWidth;
    final double heightFactor = size.height / SupportScreen._designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundMain : AppColors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar с заголовком и подзаголовком
                Padding(
                  padding: EdgeInsets.only(
                    left: scaleWidth(20),
                    top: scaleHeight(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(scaleWidth(16)),
                        child: Padding(
                          padding: EdgeInsets.all(scaleWidth(4)),
                          child: Icon(
                            Icons.arrow_back,
                            size: scaleWidth(28),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(width: scaleWidth(10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.supportTitle,
                              style: AppTextStyle.screenTitle(
                                scaleHeight(18),
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              l.supportOnlineStatus,
                              style: AppTextStyle.bodyText(
                                scaleHeight(16),
                                color: isDark
                                    ? AppColors.darkSecondaryText
                                    : const Color(0xFF5B5B5B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: scaleWidth(28)),
                    ],
                  ),
                ),
                SizedBox(height: scaleHeight(15)),
                // Чат
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: scaleWidth(24),
                      right: scaleWidth(24),
                      bottom: scaleHeight(15),
                    ),
                    child: _isLoading && _messages.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              color: isDark ? AppColors.white : AppColors.black,
                            ),
                          )
                        : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isLast = index == _messages.length - 1;
                        final showDate = _shouldShowDate(index);
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Дата (если нужно показать)
                            if (showDate && message.createdAt != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: index == 0 ? 0 : scaleHeight(20),
                                  bottom: scaleHeight(8),
                                ),
                                child: Center(
                                  child: Text(
                                    _formatDate(message.createdAt!),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w400,
                                      fontSize: scaleHeight(14),
                                      height: 24 / 14,
                                      letterSpacing: 0,
                                      color: isDark
                                          ? AppColors.darkSecondaryText
                                          : const Color(0xFF5B5B5B),
                                    ),
                                  ),
                                ),
                              ),
                            // Сообщение
                            Padding(
                          padding: EdgeInsets.only(
                            bottom: isLast ? 0 : scaleHeight(20),
                          ),
                              child: Column(
                                crossAxisAlignment: message.fromSupport
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                              // Изображения сообщения (если есть)
                              if (message.imagePaths != null && message.imagePaths!.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: message.text.isNotEmpty
                                        ? scaleHeight(8)
                                        : 0,
                                  ),
                                  child: Wrap(
                                    spacing: scaleWidth(8),
                                    runSpacing: scaleHeight(8),
                            alignment: message.fromSupport
                                        ? WrapAlignment.start
                                        : WrapAlignment.end,
                                    children: message.imagePaths!.where((imagePath) {
                                      // Фильтруем невалидные пути (например, строки JSON-массива)
                                      final trimmed = imagePath.trim();
                                      return trimmed.isNotEmpty && 
                                             !(trimmed.startsWith('[') && trimmed.endsWith(']'));
                                    }).map((imagePath) {
                                      // Если это локальные файлы (только что отправленные), показываем локально
                                      // Иначе проверяем, это URL или локальный файл
                                      final isLocal = message.isLocalFiles || !_isNetworkUrl(imagePath);
                                      final imageUrl = isLocal ? null : _getImageUrl(imagePath);
                                      
                                      return GestureDetector(
                                        onTap: () => _openImageFullScreen(imagePath),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(scaleHeight(12)),
                                          child: isLocal
                                              ? Image.file(
                                                  File(imagePath),
                                                  width: scaleHeight(100),
                                                  height: scaleHeight(100),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  imageUrl!,
                                                  width: scaleHeight(100),
                                                  height: scaleHeight(100),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: scaleHeight(100),
                                                      height: scaleHeight(100),
                                                      color: Colors.grey.withValues(alpha: 0.3),
                                                      child: Icon(
                                                        Icons.error_outline,
                                                        size: scaleWidth(24),
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                  // Текстовый бабл
                                  _SupportBubble(
                              message: message,
                              designWidth: SupportScreen._designWidth,
                              designHeight: SupportScreen._designHeight,
                            ),
                                ],
                          ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                // Выбранные изображения над текстовым полем
                if (_attachedImages.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      left: scaleWidth(17),
                      right: scaleWidth(17),
                      bottom: scaleHeight(12),
                    ),
                    child: SizedBox(
                      height: scaleHeight(100),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attachedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < _attachedImages.length - 1
                                  ? scaleWidth(10)
                                  : 0,
                            ),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => _openImageFullScreen(
                                    _attachedImages[index].path,
                                  ),
                      child: ClipRRect(
                                    borderRadius: BorderRadius.circular(scaleHeight(12)),
                        child: Image.file(
                                      File(_attachedImages[index].path),
                                      width: scaleHeight(100),
                                      height: scaleHeight(100),
                          fit: BoxFit.cover,
                        ),
                                  ),
                                ),
                                Positioned(
                                  top: scaleHeight(4),
                                  right: scaleWidth(4),
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      width: scaleWidth(24),
                                      height: scaleHeight(24),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: scaleWidth(16),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                // Поле ввода
                Padding(
                  padding: EdgeInsets.only(
                    left: scaleWidth(17),
                    right: scaleWidth(17),
                    bottom: scaleHeight(34) +
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Левая иконка (скрепка) СНАРУЖИ поля
                      GestureDetector(
                        onTap: _pickImage,
                        child: SvgPicture.asset(
                          'assets/icons/icon_clip.svg',
                          width: scaleWidth(24),
                          height: scaleWidth(24),
                          colorFilter: ColorFilter.mode(
                            isDark ? AppColors.white : AppColors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: scaleWidth(312),
                            height: scaleHeight(44),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackgroundCard
                                  : const Color(0xFFDDDDDD),
                              borderRadius:
                                  BorderRadius.circular(scaleHeight(9)),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: scaleWidth(16),
                            ),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _inputController,
                              style: AppTextStyle.bodyText(
                                scaleHeight(14),
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                      ),
                      // Правая иконка (телеграм) СНАРУЖИ поля
                      GestureDetector(
                        onTap: _isSending ? null : _sendMessage,
                        child: _isSending
                            ? SizedBox(
                                width: scaleWidth(24),
                                height: scaleWidth(24),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? AppColors.white : AppColors.black,
                                  ),
                                ),
                              )
                            : Image.asset(
                          isDark
                              ? 'assets/icons/light/icon_teleg.png'
                              : 'assets/icons/dark/icon_teleg_dark.png',
                          width: scaleWidth(24),
                          height: scaleWidth(24),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SupportMessage {
  _SupportMessage({
    required this.fromSupport,
    required this.text,
    this.imagePath,
    this.imagePaths,
    this.isLocalFiles = false, // Флаг для локальных файлов (только что отправленные)
    this.createdAt,
    this.tempId, // Временный ID для локальных сообщений
  });

  final bool fromSupport;
  final String text;
  final String? imagePath; // Для обратной совместимости
  final List<String>? imagePaths; // Для множественных изображений
  final bool isLocalFiles; // true если это локальные файлы (только что отправленные), false если URL из истории
  final DateTime? createdAt; // Дата создания сообщения
  final String? tempId; // Временный ID для локальных сообщений (для предотвращения дубликатов)
}

class _SupportBubble extends StatelessWidget {
  const _SupportBubble({
    required this.message,
    required this.designWidth,
    required this.designHeight,
  });

  final _SupportMessage message;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;

    double scaleWidth(double value) => value * widthFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleColor =
        isDark ? AppColors.darkBackgroundCard : const Color(0xFFDDDDDD);

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(15),
      topRight: const Radius.circular(15),
      bottomRight:
          message.fromSupport ? const Radius.circular(15) : Radius.zero,
      bottomLeft:
          message.fromSupport ? Radius.zero : const Radius.circular(15),
    );

    final nameText = message.fromSupport
        ? AppLocalizations.of(context)!.supportLabel
        : ProfileService.instance.fullName.isNotEmpty
            ? ProfileService.instance.fullName
            : AppLocalizations.of(context)!.supportDefaultName;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: message.fromSupport
          ? [
              // Аватар поддержки слева, прижат к низу бабла
              _Avatar(
                isSupport: true,
                designWidth: designWidth,
                designHeight: designHeight,
              ),
              SizedBox(width: scaleWidth(6)),
              _BubbleContent(
                nameText: nameText,
                messageText: message.text,
                bubbleColor: bubbleColor,
                borderRadius: borderRadius,
                designWidth: designWidth,
                designHeight: designHeight,
              ),
            ]
          : [
              // Бабл пользователя справа, аватар прижат к низу справа
              _BubbleContent(
                nameText: nameText,
                messageText: message.text,
                bubbleColor: bubbleColor,
                borderRadius: borderRadius,
                designWidth: designWidth,
                designHeight: designHeight,
                alignRight: true,
              ),
              SizedBox(width: scaleWidth(6)),
              _Avatar(
                isSupport: false,
                designWidth: designWidth,
                designHeight: designHeight,
              ),
            ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.isSupport,
    required this.designWidth,
    required this.designHeight,
  });

  final bool isSupport;
  final double designWidth;
  final double designHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;

    double scaleWidth(double value) => value * widthFactor;

    if (isSupport) {
      // logo.png 24x24 без дополнительного контейнера
      return Image.asset(
        'assets/images/logo.png',
        width: scaleWidth(24),
        height: scaleWidth(24),
        fit: BoxFit.contain,
      );
    }

    // Аватар пользователя — avatar.png 24x24
    return Image.asset(
      'assets/images/avatar.png',
      width: scaleWidth(24),
      height: scaleWidth(24),
      fit: BoxFit.cover,
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.nameText,
    required this.messageText,
    required this.bubbleColor,
    required this.borderRadius,
    required this.designWidth,
    required this.designHeight,
    this.alignRight = false,
  });

  final String nameText;
  final String messageText;
  final Color bubbleColor;
  final BorderRadius borderRadius;
  final double designWidth;
  final double designHeight;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxWidth: scaleWidth(268),
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: borderRadius,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(16),
        vertical: scaleHeight(6),
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Изображение теперь показывается в отдельном блоке сообщения,
          // поэтому внутри бабла его не рендерим.
          Text(
            nameText,
            style: AppTextStyle.bodyText(
              scaleHeight(14),
              color: isDark
                  ? AppColors.darkSecondaryText
                  : const Color(0xFF656565),
            ),
          ),
          if (messageText.isNotEmpty)
            Text(
              messageText,
              style: AppTextStyle.bodyText(
                      scaleHeight(16),
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
            ),
        ],
      ),
    );
  }
}


