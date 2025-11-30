import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/profile_service.dart';
import '../services/support_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMessageHistory();
  }

  Future<void> _loadMessageHistory() async {
    final userId = _getUserId();
    
    setState(() {
      _isLoading = true;
    });

    // Если USER_ID не найден, показываем только приветственное сообщение
    if (userId == null || userId.isEmpty) {
      debugPrint('SupportScreen: USER_ID not found, showing greeting only');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _addInitialSupportMessage();
      }
      return;
    }

    try {
      final history = await SupportService.getMessageHistory(userId);
      if (mounted) {
        setState(() {
          // Преобразуем историю в формат _SupportMessage
          _messages.clear();
          for (final msg in history) {
            List<String>? imagePaths;
            
            // Функция для безопасного парсинга строки как JSON-массива или обычной строки
            List<String> _parseImageUrls(dynamic value) {
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
                    debugPrint('SupportScreen: ошибка парсинга JSON-массива: $e, значение: $trimmed');
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
              final parsed = _parseImageUrls(msg['photo_url']);
              if (parsed.isNotEmpty) {
                imagePaths = parsed;
              }
            }
            
            // Обрабатываем photo_urls (несколько фото) - имеет приоритет над photo_url
            if (msg['photo_urls'] != null) {
              final parsed = _parseImageUrls(msg['photo_urls']);
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
                debugPrint('SupportScreen: ошибка парсинга даты: $e');
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
                debugPrint('SupportScreen: ошибка парсинга timestamp: $e');
              }
            }
            // Если дата не найдена, используем текущую дату
            createdAt ??= DateTime.now();
            
            _messages.add(
              _SupportMessage(
                fromSupport: msg['direction'] == 'support' || msg['from_support'] == true,
                text: msg['message'] ?? '',
                imagePath: singleImagePath,
                imagePaths: imagePaths,
                isLocalFiles: false, // Из истории - это URL, не локальные файлы
                createdAt: createdAt,
              ),
            );
          }
          // Если истории нет, добавляем приветственное сообщение
          if (_messages.isEmpty) {
            _addInitialSupportMessage();
          }
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('SupportScreen: ошибка загрузки истории: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // При ошибке показываем приветственное сообщение
        _addInitialSupportMessage();
      }
    }
  }

  String? _getUserId() {
    try {
      return dotenv.env['USER_ID'];
    } catch (e) {
      debugPrint('SupportScreen: ошибка получения USER_ID: $e');
      return null;
    }
  }

  Future<void> _addInitialSupportMessage() async {
    final fullName = ProfileService.instance.fullName;
    final userId = _getUserId();
    
    // Если есть userId, отправляем приветственное сообщение на сервер
    if (userId != null && userId.isNotEmpty) {
      try {
        final l = AppLocalizations.of(context)!;
        final greeting =
            '${l.supportGreetingPrefix}, ${fullName.isNotEmpty ? fullName : l.supportDefaultName}!';
        
        // Отправляем приветственное сообщение от поддержки
        await SupportService.sendMessage(
          userId: userId,
          userName: 'Support',
          message: greeting,
        );
        debugPrint('SupportScreen: приветственное сообщение отправлено на сервер');
      } catch (e) {
        debugPrint('SupportScreen: ошибка отправки приветственного сообщения: $e');
      }
    }
    
    // Добавляем сообщение в UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      final greeting =
          '${l.supportGreetingPrefix}, ${fullName.isNotEmpty ? fullName : l.supportDefaultName}!';
      if (mounted) {
        setState(() {
          _messages.add(
            _SupportMessage(
              fromSupport: true,
              text: greeting,
              isGreeting: true,
              createdAt: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
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

      final List<XFile>? files = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (files == null || files.isEmpty) return;
      
      // Ограничиваем количество до оставшихся слотов
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
      debugPrint('SupportScreen: ошибка выбора изображения: $e');
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
      debugPrint('SupportScreen: попытка открыть невалидный путь (JSON-массив): $path');
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
      debugPrint('SupportScreen: USER_ID not found, cannot send message');
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
      debugPrint('SupportScreen: сообщение отправлено успешно');
    } catch (e) {
      debugPrint('SupportScreen: ошибка отправки сообщения: $e');
      if (mounted) {
        // Удаляем сообщение из списка при ошибке
        setState(() {
          _messages.removeLast();
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
    this.isGreeting = false,
    this.imagePath,
    this.imagePaths,
    this.isLocalFiles = false, // Флаг для локальных файлов (только что отправленные)
    this.createdAt,
  });

  final bool fromSupport;
  final String text;
  final bool isGreeting;
  final String? imagePath; // Для обратной совместимости
  final List<String>? imagePaths; // Для множественных изображений
  final bool isLocalFiles; // true если это локальные файлы (только что отправленные), false если URL из истории
  final DateTime? createdAt; // Дата создания сообщения
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
                isGreeting: message.isGreeting,
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
                isGreeting: message.isGreeting,
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
    this.isGreeting = false,
  });

  final String nameText;
  final String messageText;
  final Color bubbleColor;
  final BorderRadius borderRadius;
  final double designWidth;
  final double designHeight;
  final bool alignRight;
  final bool isGreeting;

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
              style: isGreeting
                  ? AppTextStyle.screenTitle(
                      scaleHeight(16),
                      color: isDark ? AppColors.white : AppColors.black,
                    )
                  : AppTextStyle.bodyText(
                      scaleHeight(16),
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
            ),
        ],
      ),
    );
  }
}


