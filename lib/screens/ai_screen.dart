import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../utils/env_utils.dart';
import '../utils/text_utils.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({
    super.key,
    this.autoGenerateText,
    this.editText,
    this.onTextSaved,
    this.category,
    this.conversationId,
  });

  final String? autoGenerateText;
  final String? editText;
  final ValueChanged<String>? onTextSaved;
  final String? category;
  final String? conversationId; // ID чата для открытия конкретного чата

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  static const Color _primaryTextColor = AppColors.primaryText;
  static const Color _accentColor = AppColors.accentRed;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _hasConversation = false;
  Timer? _typingTimer;
  double _currentTypingIndex = 0;
  bool _isEditMode = false;
  bool _showCopyToast = false;
  Timer? _copyToastTimer;
  int? _selectedChatIndexForContextMenu;
  OverlayEntry? _chatMenuOverlay;
  bool _showScrollDownButton = false;
  bool _isLoadingChat = false; // Флаг загрузки чата по conversationId
  
  // История чатов
  final List<ChatHistory> _chatHistory = [];
  String? _currentChatId;
  int? _editingChatIndex;
  final Map<int, TextEditingController> _renameControllers = {};
  String? _currentCategory;

  // Голосовой ввод
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isRecognizing = false;
  String _recognizedText = '';
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Если передан conversationId, загружаем чат синхронно в initState
    if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
      // Устанавливаем флаги сразу, чтобы не показывать пустой экран
      _hasConversation = true;
      _isLoadingChat = true;
      // Загружаем чат асинхронно, но без видимого переключения
      _loadChatByConversationId(widget.conversationId!);
    } else {
    _initializeScreen();
    }
    _scrollController.addListener(_onScroll);
    // НЕ инициализируем речь сразу - только при первом нажатии на микрофон
    // Это предотвращает краши на iOS
  }

  Future<void> _initializeSpeech() async {
    try {
      debugPrint('🎤 [Microphone] Начало инициализации SpeechToText');
      if (!mounted) {
        debugPrint('🎤 [Microphone] Widget не mounted, прерываем инициализацию');
        return;
      }
      
      // Проверяем, не инициализирован ли уже
      if (_speech.isAvailable) {
        debugPrint('🎤 [Microphone] SpeechToText уже инициализирован, пропускаем');
        return;
      }
      
      debugPrint('🎤 [Microphone] Вызываем _speech.initialize()...');
      debugPrint('🎤 [Microphone] Платформа: ${Platform.isIOS ? "iOS" : Platform.isAndroid ? "Android" : "Other"}');
      
      // Инициализируем с обработкой ошибок
      bool? available;
      try {
        available = await _speech.initialize(
          onError: (error) {
            debugPrint('🎤 [Microphone] ОШИБКА распознавания речи в onError: $error');
            debugPrint('🎤 [Microphone] Тип ошибки: ${error.runtimeType}');
            if (mounted) {
              setState(() {
                _isListening = false;
                _isRecognizing = false;
              });
              debugPrint('🎤 [Microphone] Состояние сброшено из-за ошибки распознавания');
            }
          },
          onStatus: (status) {
            debugPrint('🎤 [Microphone] Статус распознавания речи: $status');
            if (status == 'done' && _isListening && mounted) {
              debugPrint('🎤 [Microphone] Распознавание завершено (status=done), останавливаем запись');
              _stopListening();
            }
          },
        );
        debugPrint('🎤 [Microphone] _speech.initialize() выполнен успешно');
      } catch (initError, initStackTrace) {
        debugPrint('🎤 [Microphone] ОШИБКА внутри _speech.initialize(): $initError');
        debugPrint('🎤 [Microphone] Тип ошибки: ${initError.runtimeType}');
        debugPrint('🎤 [Microphone] Stack trace: $initStackTrace');
        rethrow;
      }
      
      debugPrint('🎤 [Microphone] Инициализация SpeechToText завершена');
      debugPrint('🎤 [Microphone] Результат available: $available');
      
      // Проверяем доступность после небольшой задержки
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('🎤 [Microphone] _speech.isAvailable после задержки: ${_speech.isAvailable}');
      
      if (available == false && mounted) {
        debugPrint('🎤 [Microphone] ВНИМАНИЕ: Распознавание речи недоступно (available=false)');
      }
      
      if (mounted && !_speech.isAvailable) {
        debugPrint('🎤 [Microphone] ВНИМАНИЕ: _speech.isAvailable = false после инициализации');
      }
    } catch (e, stackTrace) {
      debugPrint('🎤 [Microphone] ОШИБКА при инициализации распознавания речи: $e');
      debugPrint('🎤 [Microphone] Тип ошибки: ${e.runtimeType}');
      debugPrint('🎤 [Microphone] Stack trace: $stackTrace');
      // Пробрасываем ошибку дальше, чтобы обработать в вызывающем коде
      rethrow;
    }
  }
  
  @override
  void didUpdateWidget(AiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Если conversationId изменился, загружаем новый чат
    if (widget.conversationId != null && 
        widget.conversationId!.isNotEmpty && 
        widget.conversationId != oldWidget.conversationId) {
      // Устанавливаем флаги сразу
      _hasConversation = true;
      _isLoadingChat = true;
      // Загружаем новый чат
      _loadChatByConversationId(widget.conversationId!);
    }
  }
  
  // Загрузка чата по conversationId без видимого переключения
  Future<void> _loadChatByConversationId(String conversationId) async {
    try {
      // Загружаем историю чатов
      await _loadConversationsFromApi();
      
      if (!mounted) return;
      
      // Ищем чат с нужным conversationId
      final chatIndex = _chatHistory.indexWhere(
        (chat) => chat.conversationId == conversationId,
      );
      
      if (chatIndex != -1) {
        // Открываем найденный чат без видимого переключения
        final chat = _chatHistory[chatIndex];
        
        // Загружаем историю чата БЕЗ промежуточных setState
        // Сначала загружаем данные, потом одним setState обновляем UI
        if (chat.conversationId != null && chat.conversationId!.isNotEmpty) {
          try {
            final historyResult = await ApiService.instance.getChatHistory(chat.conversationId!);
            
            if (!mounted) return;

            if (historyResult.containsKey('error')) {
              if (mounted) {
                setState(() {
                  _isLoadingChat = false;
                });
              }
              return;
            }

            // Получаем conversation_id из ответа
            final responseConversationId = historyResult['conversation_id'] as String?;
            final actualConversationId = responseConversationId ?? chat.conversationId!;

            // Парсим attachments (файлы привязанные к сообщениям по message_id)
            final attachmentsList = historyResult['attachments'] as List<dynamic>? ?? [];
            final Map<String, List<Map<String, dynamic>>> filesByMessageId = {};
            
            for (final attachment in attachmentsList) {
              final messageId = attachment['message_id'] as String?;
              final files = attachment['files'] as List<dynamic>?;
              
              if (messageId != null && files != null && files.isNotEmpty) {
                filesByMessageId[messageId] = List<Map<String, dynamic>>.from(
                  files.map((file) => file as Map<String, dynamic>)
                );
              }
            }

            // Преобразуем сообщения из API в ChatMessage
            final messagesList = historyResult['messages'] as List<dynamic>? ?? [];
            final List<ChatMessage> loadedMessages = [];
            
            for (final msg in messagesList) {
              final content = msg['content'] as String? ?? '';
              final role = msg['role'] as String? ?? '';
              final isUser = role == 'user';
              final messageId = msg['id'] as String?;
              
              // Получаем файлы из attachments по message_id
              List<Map<String, dynamic>>? files;
              if (messageId != null && filesByMessageId.containsKey(messageId)) {
                files = filesByMessageId[messageId];
              }
              
              loadedMessages.add(ChatMessage(
                text: TextUtils.safeText(content),
                isUser: isUser,
                isThinking: false,
                files: files,
              ));
            }

            // Обновляем сообщения и историю чата ОДНИМ setState
            if (mounted) {
              setState(() {
                _currentChatId = chat.id;
                _messages.clear();
                _messages.addAll(loadedMessages);
                _hasConversation = true;
                
                // Обновляем историю чата с правильным conversation_id
                final chatIndex = _chatHistory.indexWhere((c) => c.id == chat.id);
                if (chatIndex != -1) {
                  _chatHistory[chatIndex] = ChatHistory(
                    id: _chatHistory[chatIndex].id,
                    title: _chatHistory[chatIndex].title,
                    messages: List.from(_messages),
                    conversationId: actualConversationId,
                  );
                }
                
                _isLoadingChat = false; // Загрузка завершена
              });
              
              _scrollToBottom();
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isLoadingChat = false;
              });
            }
          }
        }
      } else {
        // Если чат не найден, создаем новый с этим conversationId и загружаем его историю
        setState(() {
          final newChat = ChatHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Новый чат',
            messages: [],
            conversationId: conversationId,
          );
          _chatHistory.insert(0, newChat);
          _currentChatId = newChat.id;
        });
        
        // Загружаем историю нового чата
        try {
          final historyResult = await ApiService.instance.getChatHistory(conversationId);
          
          if (!mounted) return;

          if (!historyResult.containsKey('error')) {
            // Парсим attachments (файлы привязанные к сообщениям по message_id)
            final attachmentsList = historyResult['attachments'] as List<dynamic>? ?? [];
            final Map<String, List<Map<String, dynamic>>> filesByMessageId = {};
            
            for (final attachment in attachmentsList) {
              final messageId = attachment['message_id'] as String?;
              final files = attachment['files'] as List<dynamic>?;
              
              if (messageId != null && files != null && files.isNotEmpty) {
                filesByMessageId[messageId] = List<Map<String, dynamic>>.from(
                  files.map((file) => file as Map<String, dynamic>)
                );
              }
            }

            final messagesList = historyResult['messages'] as List<dynamic>? ?? [];
            final List<ChatMessage> loadedMessages = [];
            
            for (final msg in messagesList) {
              final content = msg['content'] as String? ?? '';
              final role = msg['role'] as String? ?? '';
              final isUser = role == 'user';
              final messageId = msg['id'] as String?;
              
              // Получаем файлы из attachments по message_id
              List<Map<String, dynamic>>? files;
              if (messageId != null && filesByMessageId.containsKey(messageId)) {
                files = filesByMessageId[messageId];
              }
              
              loadedMessages.add(ChatMessage(
                text: TextUtils.safeText(content),
                isUser: isUser,
                isThinking: false,
                files: files,
              ));
            }

            if (mounted) {
              setState(() {
                _messages.clear();
                _messages.addAll(loadedMessages);
                _isLoadingChat = false;
              });
              
              _scrollToBottom();
            }
          } else {
            if (mounted) {
              setState(() {
                _isLoadingChat = false;
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoadingChat = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingChat = false;
        });
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isAtBottom = (maxScroll - currentScroll) < 100; // 100 пикселей от низа
    
    if (_showScrollDownButton != !isAtBottom) {
      setState(() {
        _showScrollDownButton = !isAtBottom;
      });
    }
  }

  void _initializeScreen() {
    // Сохраняем категорию если она передана
    if (widget.category != null) {
      _currentCategory = widget.category;
    }
    
    // Если передан conversationId, сразу загружаем чат (синхронно)
    if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
      setState(() {
        _isLoadingChat = true;
        _hasConversation = true; // Сразу показываем, что есть чат
      });
      // Загружаем чат асинхронно, но без видимого переключения
      _openChatByConversationId(widget.conversationId!);
      return;
    }
    
    // Если передан текст для редактирования, загружаем его в поле ввода
    if (widget.editText != null) {
      _inputController.text = TextUtils.safeText(widget.editText);
      _isEditMode = true;
    }
    // Если передан текст для автогенерации, запускаем генерацию
    else if (widget.autoGenerateText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessageWithApi(widget.autoGenerateText!, category: widget.category);
      });
    }
  }
  
  // Открыть чат по conversationId
  Future<void> _openChatByConversationId(String conversationId) async {
    try {
      // Загружаем историю чатов
      await _loadConversationsFromApi();
      
      if (!mounted) return;
      
      // Ищем чат с нужным conversationId
      final chatIndex = _chatHistory.indexWhere(
        (chat) => chat.conversationId == conversationId,
      );
      
      if (chatIndex != -1) {
        // Открываем найденный чат
        await _openChat(chatIndex);
      } else {
        // Если чат не найден, создаем новый с этим conversationId
        setState(() {
          final newChat = ChatHistory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Новый чат',
            messages: [],
            conversationId: conversationId,
          );
          _chatHistory.insert(0, newChat);
          _currentChatId = newChat.id;
        });
        
        // Загружаем историю этого чата
        final chatIndex = _chatHistory.indexWhere((c) => c.id == _currentChatId);
        if (chatIndex != -1) {
          await _openChat(chatIndex);
        }
      }
      
      if (mounted) {
        setState(() {
          _isLoadingChat = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingChat = false;
        });
      }
    }
  }

  Future<void> _sendMessageWithApi(String message, {String? category}) async {
    // Получаем user_id из .env
    String? userId;
    try {
      await dotenv.load(fileName: ".env");
      await EnvUtils.mergeRuntimeEnvIntoDotenv();
      userId = dotenv.env['USER_ID'];
      debugPrint('AiScreen: USER_ID from .env: ${userId != null && userId.isNotEmpty ? "${userId.substring(0, 8)}..." : "not found"}');
    } catch (e) {
      debugPrint('AiScreen: error loading .env: $e');
    }
    
    // Если user_id не найден в .env, используем дефолтный
    if (userId == null || userId.isEmpty) {
      userId = 'f30dea45-7689-4293-aff5-7e68dd031fa6';
      debugPrint('AiScreen: using default USER_ID: ${userId.substring(0, 8)}...');
    }

    // Получаем conversation_id из текущего чата
    String? conversationId;
    if (_currentChatId != null) {
      final chatIndex = _chatHistory.indexWhere((chat) => chat.id == _currentChatId);
      if (chatIndex != -1) {
        conversationId = _chatHistory[chatIndex].conversationId;
      }
    }

    // Добавляем сообщение пользователя
    setState(() {
      _hasConversation = true;
      _messages.add(ChatMessage(text: TextUtils.safeText(message), isUser: true));
      _isTyping = false;
      _currentTypingIndex = 0;
      _messages.add(const ChatMessage(text: '', isUser: false, isThinking: true));
    });

    _scrollToBottom();

    try {
      // Отправляем запрос на API
      final result = await ApiService.instance.sendMessage(
        userId: userId,
        message: message,
        category: category,
        conversationId: conversationId,
      );

      if (!mounted) return;

      if (result.containsKey('error')) {
        // Ошибка при отправке
        setState(() {
          _isTyping = false;
          _messages.removeLast(); // Удаляем пустое сообщение
          _messages.add(ChatMessage(
            text: 'Ошибка: ${result['error']}',
            isUser: false,
            isThinking: false,
          ));
        });
        _scrollToBottom();
        return;
      }

      // Успешный ответ - переходим от "думает" к генерации
      final responseText = TextUtils.safeText(result['response'] as String? ?? '');
      final newConversationId = result['conversation_id'] as String?;
      
      // Парсим файлы из ответа
      List<Map<String, dynamic>>? files;
      if (result['files'] != null && result['files'] != 'null') {
        if (result['files'] is List) {
          files = List<Map<String, dynamic>>.from(
            (result['files'] as List).map((file) => file as Map<String, dynamic>)
          );
        }
      }
      
      setState(() {
        _isTyping = true; // Начинаем генерацию
      });

      // Сохраняем conversation_id в текущий чат
      if (newConversationId != null && newConversationId.isNotEmpty) {
        if (_currentChatId != null) {
          final chatIndex = _chatHistory.indexWhere((chat) => chat.id == _currentChatId);
          if (chatIndex != -1) {
            setState(() {
              _chatHistory[chatIndex] = ChatHistory(
                id: _chatHistory[chatIndex].id,
                title: _chatHistory[chatIndex].title,
                messages: List.from(_messages),
                conversationId: newConversationId, // Сохраняем conversation_id для дальнейших сообщений
              );
            });
          }
        }
      }

      // Отображаем ответ с анимацией печати
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
      setState(() {
          if (_currentTypingIndex >= responseText.length) {
          timer.cancel();
            _messages[_messages.length - 1] = ChatMessage(
              text: responseText,
            isUser: false,
            isThinking: false,
            files: files, // Добавляем файлы в сообщение
          );
          _isTyping = false;
            // Сохраняем чат после завершения генерации
            _saveCurrentChat();
            // Отправляем уведомление о завершении генерации (только если приложение не активно)
            NotificationService.instance.showAiMessageNotification(
              responseText,
              conversationId: newConversationId,
            );
        } else {
          _currentTypingIndex += 1;
            _messages[_messages.length - 1] = ChatMessage(
              text: TextUtils.safeText(responseText.substring(0, _currentTypingIndex.toInt())),
            isUser: false,
            isThinking: false,
          );
        }
      });
      _scrollToBottom();
    });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.removeLast(); // Удаляем пустое сообщение
        _messages.add(ChatMessage(
          text: 'Ошибка при отправке сообщения: $e',
          isUser: false,
          isThinking: false,
        ));
      });
      _scrollToBottom();
    }
  }

  Future<void> _loadConversationsFromApi({VoidCallback? onOverlayUpdate}) async {
    try {
      // Получаем user_id из .env
      await dotenv.load(fileName: ".env");
      await EnvUtils.mergeRuntimeEnvIntoDotenv();
      final userId = dotenv.env['USER_ID']?.trim();
      
      if (userId == null || userId.isEmpty) {
        debugPrint('AiScreen: USER_ID not found in .env, skipping conversations load');
        return;
      }

      // Отправляем GET запрос на получение списка чатов
      final result = await ApiService.instance.getConversations(userId);
      
      if (!mounted) return;

      if (result.containsKey('error')) {
        debugPrint('AiScreen: error loading conversations: ${result['error']}');
        return;
      }

      // Преобразуем ответ в список ChatHistory
      final conversationsList = result['conversations'] as List<dynamic>? ?? [];
      final List<ChatHistory> loadedChats = [];
      
      for (final conv in conversationsList) {
        final id = conv['id'] as String? ?? '';
        final title = conv['title'] as String? ?? '';
        final conversationId = id; // conversation_id это id из ответа
        
        if (id.isNotEmpty && title.isNotEmpty) {
          loadedChats.add(ChatHistory(
            id: id,
            title: _stripMarkdown(title),
            messages: [], // Сообщения загрузятся при открытии чата
            conversationId: conversationId,
          ));
        }
      }

      // Обновляем историю чатов
      if (!mounted) return;

      setState(() {
        _chatHistory
          ..clear()
          ..addAll(loadedChats);
      });

      // Обновляем overlay, если он открыт
      onOverlayUpdate?.call();
    } catch (e) {
      debugPrint('AiScreen: error loading conversations from API: $e');
    }
  }

  void _showChatMenuOverlay() {
    if (_chatMenuOverlay != null) {
      _chatMenuOverlay!.remove();
      _chatMenuOverlay = null;
    }
    
    // Загружаем чаты с API при открытии меню
    _loadConversationsFromApi(onOverlayUpdate: () {
      // Обновляем overlay после загрузки данных
      _chatMenuOverlay?.markNeedsBuild();
    });
    
    final overlay = Overlay.of(context);
    _chatMenuOverlay = OverlayEntry(
      builder: (context) => StatefulBuilder(
        builder: (context, setOverlayState) {
          return _ChatMenuDrawer(
            designWidth: _designWidth,
            designHeight: _designHeight,
            onClose: () {
              _hideChatMenuOverlay();
            },
            onNewChat: () {
              setState(() {
                _saveCurrentChat(); // Сохраняем текущий чат перед созданием нового
        _currentChatId = null;
                _messages.clear();
                _hasConversation = false;
                _inputController.clear();
              });
              _hideChatMenuOverlay();
            },
            chatHistory: _chatHistory,
            editingChatIndex: _editingChatIndex,
            renameControllers: _renameControllers,
            onChatTap: (index) {
              _openChat(index);
              setOverlayState(() {});
            },
            onDeleteChat: (index) {
              _deleteChat(index);
              setOverlayState(() {});
            },
            onRenameChat: (index) {
              _startRenamingChat(index);
              setOverlayState(() {});
            },
            onSaveRename: (index) {
              _saveRenamedChat(index);
              setOverlayState(() {});
            },
            onCancelRename: () {
              _cancelRenamingChat();
              setOverlayState(() {});
            },
            selectedChatIndex: _selectedChatIndexForContextMenu,
            onChatSelected: (index) {
              setState(() {
                _selectedChatIndexForContextMenu = index;
              });
              setOverlayState(() {});
            },
            onContextMenuClosed: () {
              setState(() {
                _selectedChatIndexForContextMenu = null;
              });
              setOverlayState(() {});
            },
          );
        },
      ),
    );
    overlay.insert(_chatMenuOverlay!);
  }

  void _hideChatMenuOverlay() {
    _chatMenuOverlay?.remove();
    _chatMenuOverlay = null;
    setState(() {
      _selectedChatIndexForContextMenu = null;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _copyToastTimer?.cancel();
    _recordingTimer?.cancel();
    _speech.stop();
    _chatMenuOverlay?.remove();
    _inputController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    for (var controller in _renameControllers.values) {
      controller.dispose();
    }
    _renameControllers.clear();
    super.dispose();
  }
  
  Future<void> _openChat(int index) async {
    if (index >= 0 && index < _chatHistory.length) {
      _saveCurrentChat(); // Сохраняем текущий чат перед открытием другого
      final chat = _chatHistory[index];
      
      setState(() {
        _currentChatId = chat.id;
        _messages.clear();
        _hasConversation = true;
        _isLoadingChat = false; // Сбрасываем флаг загрузки при открытии чата
        _hideChatMenuOverlay();
      });

      // Загружаем историю с API используя conversation_id (который равен id чата)
      if (chat.conversationId != null && chat.conversationId!.isNotEmpty) {
        try {
          final historyResult = await ApiService.instance.getChatHistory(chat.conversationId!);
          
          if (!mounted) return;

          if (historyResult.containsKey('error')) {
            // Ошибка при загрузке истории
            debugPrint('AiScreen: error loading chat history: ${historyResult['error']}');
            _scrollToBottom();
            return;
          }

          // Получаем conversation_id из ответа (может отличаться от id чата)
          final responseConversationId = historyResult['conversation_id'] as String?;
          final actualConversationId = responseConversationId ?? chat.conversationId!;

          // Парсим attachments (файлы привязанные к сообщениям по message_id)
          final attachmentsList = historyResult['attachments'] as List<dynamic>? ?? [];
          final Map<String, List<Map<String, dynamic>>> filesByMessageId = {};
          
          for (final attachment in attachmentsList) {
            final messageId = attachment['message_id'] as String?;
            final files = attachment['files'] as List<dynamic>?;
            
            if (messageId != null && files != null && files.isNotEmpty) {
              filesByMessageId[messageId] = List<Map<String, dynamic>>.from(
                files.map((file) => file as Map<String, dynamic>)
              );
            }
          }

          // Преобразуем сообщения из API в ChatMessage
          final messagesList = historyResult['messages'] as List<dynamic>? ?? [];
          final List<ChatMessage> loadedMessages = [];
          
          for (final msg in messagesList) {
            final content = msg['content'] as String? ?? '';
            final role = msg['role'] as String? ?? '';
            final isUser = role == 'user';
            final messageId = msg['id'] as String?;
            
            // Получаем файлы из attachments по message_id
            List<Map<String, dynamic>>? files;
            if (messageId != null && filesByMessageId.containsKey(messageId)) {
              files = filesByMessageId[messageId];
            }
            
            loadedMessages.add(ChatMessage(
              text: content,
              isUser: isUser,
              isThinking: false,
              files: files,
            ));
          }

          // Обновляем сообщения и историю чата
          setState(() {
            _messages.clear();
            _messages.addAll(loadedMessages);
            
            // Обновляем историю чата с правильным conversation_id
            final chatIndex = _chatHistory.indexWhere((c) => c.id == chat.id);
            if (chatIndex != -1) {
              _chatHistory[chatIndex] = ChatHistory(
                id: _chatHistory[chatIndex].id,
                title: _chatHistory[chatIndex].title,
                messages: loadedMessages,
                conversationId: actualConversationId, // Используем conversation_id из ответа
              );
            }
          });
          
          _scrollToBottom();
        } catch (e) {
          debugPrint('AiScreen: error loading chat history: $e');
          _scrollToBottom();
        }
      } else {
        // Нет conversation_id
        _scrollToBottom();
      }
    }
  }
  
  Future<void> _deleteChat(int index) async {
    if (index >= 0 && index < _chatHistory.length) {
      try {
        await dotenv.load(fileName: ".env");
        await EnvUtils.mergeRuntimeEnvIntoDotenv();
        final userId = dotenv.env['USER_ID']?.trim();

        if (userId == null || userId.isEmpty) {
          debugPrint('AiScreen: USER_ID not found in .env, delete skipped');
          return;
        }

        final chatId = _chatHistory[index].id;
        final success = await ApiService.instance.deleteConversation(
          userId: userId,
          conversationId: chatId,
        );

        if (!success) {
          debugPrint('AiScreen: delete conversation failed for $chatId');
          return;
        }

        if (!mounted) return;

        setState(() {
          if (_currentChatId != null && _chatHistory[index].id == _currentChatId) {
            _currentChatId = null;
            _messages.clear();
            _hasConversation = false;
          }
          if (_renameControllers.containsKey(index)) {
            _renameControllers[index]?.dispose();
            _renameControllers.remove(index);
          }
          final newControllers = <int, TextEditingController>{};
          for (var entry in _renameControllers.entries) {
            if (entry.key > index) {
              newControllers[entry.key - 1] = entry.value;
            } else if (entry.key < index) {
              newControllers[entry.key] = entry.value;
            }
          }
          _renameControllers
            ..clear()
            ..addAll(newControllers);
          if (_editingChatIndex == index) {
            _editingChatIndex = null;
          } else if (_editingChatIndex != null && _editingChatIndex! > index) {
            _editingChatIndex = _editingChatIndex! - 1;
          }
          _chatHistory.removeAt(index);
        });

        _chatMenuOverlay?.markNeedsBuild();
      } catch (e) {
        debugPrint('AiScreen: error deleting chat: $e');
      }
    }
  }
  
  void _startRenamingChat(int index) {
    if (index >= 0 && index < _chatHistory.length) {
      setState(() {
        _editingChatIndex = index;
        if (!_renameControllers.containsKey(index)) {
          _renameControllers[index] = TextEditingController(text: _chatHistory[index].title);
        }
      });
      // Обновляем Overlay, чтобы показать TextField
      if (_chatMenuOverlay != null) {
        _chatMenuOverlay!.markNeedsBuild();
      }
    }
  }
  
  Future<void> _saveRenamedChat(int index) async {
    if (index >= 0 && index < _chatHistory.length && _renameControllers.containsKey(index)) {
      final newTitle = _renameControllers[index]!.text.trim();
      if (newTitle.isEmpty) return;

      try {
        await dotenv.load(fileName: ".env");
        await EnvUtils.mergeRuntimeEnvIntoDotenv();
        final userId = dotenv.env['USER_ID']?.trim();

        if (userId == null || userId.isEmpty) {
          debugPrint('AiScreen: USER_ID not found in .env, rename skipped');
          return;
        }

        final chatId = _chatHistory[index].id;
        final result = await ApiService.instance.renameConversation(
          userId: userId,
          conversationId: chatId,
          title: newTitle,
        );

        if (result.containsKey('error')) {
          debugPrint('AiScreen: rename conversation failed: ${result['error']}');
          return;
        }

        if (!mounted) return;

        setState(() {
          _chatHistory[index] = ChatHistory(
            id: _chatHistory[index].id,
            title: newTitle,
            messages: _chatHistory[index].messages,
            conversationId: _chatHistory[index].conversationId,
          );
          _editingChatIndex = null;
        });

        _chatMenuOverlay?.markNeedsBuild();
      } catch (e) {
        debugPrint('AiScreen: error renaming chat: $e');
      }
    }
  }
  
  void _cancelRenamingChat() {
    setState(() {
      _editingChatIndex = null;
    });
    // Обновляем Overlay после отмены
    if (_chatMenuOverlay != null) {
      _chatMenuOverlay!.markNeedsBuild();
    }
  }
  
  void _saveCurrentChat() {
    if (_messages.isNotEmpty && _currentChatId != null) {
      final chatIndex = _chatHistory.indexWhere((chat) => chat.id == _currentChatId);
      if (chatIndex != -1) {
        setState(() {
          _chatHistory[chatIndex] = ChatHistory(
            id: _chatHistory[chatIndex].id,
            title: _chatHistory[chatIndex].title,
            messages: List.from(_messages),
            conversationId: _chatHistory[chatIndex].conversationId,
          );
        });
      }
    }
  }

  void _showCopyToastOnce() {
    _copyToastTimer?.cancel();
    setState(() {
      _showCopyToast = true;
    });
    _copyToastTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _showCopyToast = false;
      });
    });
  }

  // Функция для удаления markdown-символов из текста
  static String _stripMarkdown(String text) {
    if (text.isEmpty) return text;
    
    // Удаляем markdown-символы форматирования
    String result = text;
    
    // Удаляем ** для жирности (может быть несколько подряд)
    result = result.replaceAll(RegExp(r'\*\*+'), '');
    
    // Удаляем * для курсива (но не если это часть **)
    result = result.replaceAll(RegExp(r'(?<!\*)\*(?!\*)'), '');
    
    // Удаляем > для цитат
    result = result.replaceAll(RegExp(r'^>\s*', multiLine: true), '');
    
    // Удаляем # для заголовков
    result = result.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    
    // Удаляем ` для кода (одиночные и тройные)
    result = result.replaceAll(RegExp(r'```+'), '');
    result = result.replaceAll(RegExp(r'`'), '');
    
    // Удаляем [] для ссылок
    result = result.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    
    // Удаляем лишние пробелы
    result = result.trim();
    
    return result;
  }

  // Методы для голосового ввода
  Future<void> _startListening() async {
    try {
      debugPrint('🎤 [Microphone] Начало запроса разрешения на микрофон');
      
      // Проверяем текущий статус разрешения
      PermissionStatus status = await Permission.microphone.status;
      debugPrint('🎤 [Microphone] Текущий статус разрешения: $status');
      debugPrint('🎤 [Microphone] isGranted: ${status.isGranted}');
      debugPrint('🎤 [Microphone] isDenied: ${status.isDenied}');
      debugPrint('🎤 [Microphone] isPermanentlyDenied: ${status.isPermanentlyDenied}');
      
      // Если разрешение не предоставлено, запрашиваем его
      if (!status.isGranted) {
        // Если разрешение уже было отклонено навсегда, открываем настройки
        if (status.isPermanentlyDenied) {
          debugPrint('🎤 [Microphone] Разрешение уже было отклонено навсегда ранее, открываем настройки приложения');
          if (mounted) {
            await openAppSettings();
            debugPrint('🎤 [Microphone] Настройки приложения открыты');
          }
          return;
        }
        
        // Запрашиваем разрешение через permission_handler
        // НЕ инициализируем speech_to_text до получения разрешения, чтобы избежать краша
        debugPrint('🎤 [Microphone] Статус denied, запрашиваем разрешение через Permission.microphone.request()');
        try {
          status = await Permission.microphone.request();
          debugPrint('🎤 [Microphone] Статус после request(): $status');
          debugPrint('🎤 [Microphone] isGranted после запроса: ${status.isGranted}');
          debugPrint('🎤 [Microphone] isDenied после запроса: ${status.isDenied}');
          debugPrint('🎤 [Microphone] isPermanentlyDenied после запроса: ${status.isPermanentlyDenied}');
        } catch (e, stackTrace) {
          debugPrint('🎤 [Microphone] ОШИБКА при запросе разрешения: $e');
          debugPrint('🎤 [Microphone] Stack trace: $stackTrace');
          return;
        }
        
        // Если после запроса разрешение все еще не предоставлено
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            // Если разрешение отклонено навсегда, открываем настройки
            debugPrint('🎤 [Microphone] После запроса статус стал permanentlyDenied');
            debugPrint('🎤 [Microphone] На iOS это может означать, что диалог не был показан');
            debugPrint('🎤 [Microphone] Или пользователь ранее отклонил разрешение');
            debugPrint('🎤 [Microphone] Открываем настройки приложения');
            if (mounted) {
              await openAppSettings();
              debugPrint('🎤 [Microphone] Настройки приложения открыты');
            }
          } else {
            // Пользователь отклонил запрос в системном диалоге (но не навсегда)
            debugPrint('🎤 [Microphone] Пользователь отклонил запрос разрешения в системном диалоге');
            debugPrint('🎤 [Microphone] Статус: denied (не permanentlyDenied), можно запросить снова позже');
          }
          return;
        } else {
          debugPrint('🎤 [Microphone] ✅ Разрешение предоставлено пользователем');
        }
      } else {
        debugPrint('🎤 [Microphone] ✅ Разрешение уже было предоставлено ранее');
      }

      debugPrint('🎤 [Microphone] Инициализация распознавания речи');
      
      // Ждем немного после получения разрешения, чтобы iOS успел применить его
      debugPrint('🎤 [Microphone] Ожидание применения разрешения (500ms)...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) {
        debugPrint('🎤 [Microphone] Widget не mounted после ожидания, прерываем');
        return;
      }
      
      // Инициализируем речь, если еще не инициализирована
      if (!_speech.isAvailable) {
        debugPrint('🎤 [Microphone] SpeechToText не инициализирован, запускаем инициализацию');
        
        try {
          // Инициализируем напрямую с обработкой ошибок
          await _initializeSpeech();
          debugPrint('🎤 [Microphone] Инициализация завершена, isAvailable: ${_speech.isAvailable}');
          
          // Ждем немного после инициализации для стабильности
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e, stackTrace) {
          debugPrint('🎤 [Microphone] ОШИБКА при инициализации SpeechToText: $e');
          debugPrint('🎤 [Microphone] Тип ошибки: ${e.runtimeType}');
          debugPrint('🎤 [Microphone] Stack trace: $stackTrace');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка при инициализации распознавания речи')),
            );
          }
          return;
        }
      } else {
        debugPrint('🎤 [Microphone] SpeechToText уже инициализирован');
      }

      if (!mounted || !_speech.isAvailable) {
        debugPrint('🎤 [Microphone] ОШИБКА: Распознавание речи недоступно после инициализации');
        debugPrint('🎤 [Microphone] mounted: $mounted, isAvailable: ${_speech.isAvailable}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Распознавание речи недоступно')),
          );
        }
        return;
      }
      
      if (!mounted) {
        debugPrint('🎤 [Microphone] Widget не mounted, прерываем');
        return;
      }
      
      debugPrint('🎤 [Microphone] Начинаем запись голоса');
    } catch (e, stackTrace) {
      debugPrint('Error in _startListening: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при запуске записи голоса')),
        );
      }
      return;
    }

    if (!mounted) return;

    debugPrint('🎤 [Microphone] Устанавливаем состояние записи');
    setState(() {
      _isListening = true;
      _isRecognizing = false;
      _recognizedText = '';
      _recordingSeconds = 0;
    });

    // Запускаем таймер для отсчета времени
    debugPrint('🎤 [Microphone] Запускаем таймер отсчета времени');
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isListening) {
        debugPrint('🎤 [Microphone] Таймер остановлен: mounted=$mounted, isListening=$_isListening');
        timer.cancel();
        return;
      }
      setState(() {
        _recordingSeconds++;
      });
      if (_recordingSeconds % 10 == 0) {
        debugPrint('🎤 [Microphone] Запись продолжается: ${_formatRecordingTime(_recordingSeconds)}');
      }
    });

    try {
      debugPrint('🎤 [Microphone] Вызываем _speech.listen()');
      await _speech.listen(
        onResult: (result) {
          debugPrint('🎤 [Microphone] Получен результат распознавания: ${result.recognizedWords}');
          debugPrint('🎤 [Microphone] Финальный результат: ${result.finalResult}');
          if (mounted && _isListening) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          }
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        localeId: 'ru_RU',
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('🎤 [Microphone] ОШИБКА при запуске распознавания речи: $e');
      debugPrint('🎤 [Microphone] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isListening = false;
          _isRecognizing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при запуске записи голоса')),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) {
      debugPrint('🎤 [Microphone] _stopListening вызван, но запись не активна');
      return;
    }

    debugPrint('🎤 [Microphone] Остановка записи голоса');
    debugPrint('🎤 [Microphone] Время записи: ${_formatRecordingTime(_recordingSeconds)}');
    debugPrint('🎤 [Microphone] Распознанный текст до остановки: $_recognizedText');

    try {
      _recordingTimer?.cancel();
      debugPrint('🎤 [Microphone] Таймер остановлен');
      
      if (_speech.isListening) {
        debugPrint('🎤 [Microphone] Останавливаем _speech.listen()');
        await _speech.stop();
        debugPrint('🎤 [Microphone] _speech.stop() выполнен');
      } else {
        debugPrint('🎤 [Microphone] _speech.isListening = false, остановка не требуется');
      }

      if (!mounted) {
        debugPrint('🎤 [Microphone] Widget не mounted после остановки, прерываем');
        return;
      }

      // Сохраняем распознанный текст перед сбросом состояния
      final finalText = _recognizedText.trim();
      debugPrint('🎤 [Microphone] Финальный распознанный текст: "$finalText"');
      
      setState(() {
        _isListening = false;
        _isRecognizing = true;
        _recordingSeconds = 0;
      });
      debugPrint('🎤 [Microphone] Состояние установлено: isListening=false, isRecognizing=true');

      // Ждем немного для получения финального результата
      debugPrint('🎤 [Microphone] Ожидание финального результата (500ms)');
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        debugPrint('🎤 [Microphone] Widget не mounted после ожидания, прерываем');
        return;
      }

      // Вставляем распознанный текст в поле ввода
      debugPrint('🎤 [Microphone] Вставка распознанного текста в поле ввода');
      setState(() {
        _isRecognizing = false;
        if (finalText.isNotEmpty) {
          // Если в текстовом поле уже есть текст, добавляем распознанный текст к существующему
          final existingText = _inputController.text.trim();
          debugPrint('🎤 [Microphone] Существующий текст в поле: "$existingText"');
          if (existingText.isNotEmpty) {
            _inputController.text = '$existingText $finalText';
            debugPrint('🎤 [Microphone] Текст добавлен к существующему: "${_inputController.text}"');
          } else {
            _inputController.text = finalText;
            debugPrint('🎤 [Microphone] Текст вставлен в пустое поле: "${_inputController.text}"');
          }
        } else {
          debugPrint('🎤 [Microphone] Распознанный текст пуст, поле ввода не изменено');
        }
      });
      debugPrint('🎤 [Microphone] Распознавание завершено, состояние: isRecognizing=false');
    } catch (e, stackTrace) {
      debugPrint('🎤 [Microphone] ОШИБКА при остановке распознавания речи: $e');
      debugPrint('🎤 [Microphone] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isListening = false;
          _isRecognizing = false;
          _recordingSeconds = 0;
        });
        debugPrint('🎤 [Microphone] Состояние сброшено из-за ошибки');
      }
    }
  }

  String _formatRecordingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = TextUtils.safeText(_inputController.text.trim());
    if (text.isEmpty || _isTyping) {
      return;
    }

    // Если режим редактирования, сохраняем текст и выходим из режима редактирования
    if (_isEditMode && widget.onTextSaved != null) {
      widget.onTextSaved!(text);
      _isEditMode = false;
      _currentCategory = null; // Сбрасываем категорию после редактирования
      // После сохранения продолжаем обычный чат
      FocusScope.of(context).unfocus();
      _sendMessageWithApi(text);
      _inputController.clear();
      return;
    }

    // Обычная отправка сообщения
    FocusScope.of(context).unfocus();
    
    // Если это новый чат, создаем его при первом сообщении
    if (_currentChatId == null) {
      final cleanTitle = _stripMarkdown(text);
      final newChat = ChatHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: cleanTitle.length > 30 ? '${cleanTitle.substring(0, 30)}...' : cleanTitle,
        messages: [],
      );
      _chatHistory.insert(0, newChat);
      _currentChatId = newChat.id;
    }
    
    _inputController.clear();
    _sendMessageWithApi(text, category: _currentCategory);
    _currentCategory = null; // Сбрасываем категорию после отправки
  }

  void _stopGeneration() {
    if (!_isTyping) return;
    _typingTimer?.cancel();
    setState(() {
      _isTyping = false;
    });
    _scrollToBottom();
  }

  Widget _buildRecordingUI(bool isDark, double Function(double) scaleWidth, double Function(double) scaleHeight) {
    // Во время записи показываем время и "Говорите"
    return Row(
      children: [
        Text(
          _formatRecordingTime(_recordingSeconds),
          style: AppTextStyle.bodyTextMedium(
            scaleHeight(16),
            color: isDark ? AppColors.white : _primaryTextColor,
          ),
        ),
        SizedBox(width: scaleWidth(8)),
        Text(
          'Говорите',
          style: AppTextStyle.bodyTextMedium(
            scaleHeight(16),
            color: isDark ? AppColors.white : _primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRecognizingText(bool isDark, double Function(double) scaleWidth, double Function(double) scaleHeight) {
    return _RecognizingTextAnimation(
      baseText: 'Распознание голоса',
      isDark: isDark,
      scaleWidth: scaleWidth,
      scaleHeight: scaleHeight,
    );
  }




  // Функция для скачивания и обработки файла
  Future<void> _downloadAndShareFile(String downloadUrl, String filename) async {
    try {
      // Показываем индикатор загрузки
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Формируем полный URL
      const baseUrl = 'http://84.201.149.99:8080';
      final fullUrl = downloadUrl.startsWith('/') 
          ? '$baseUrl$downloadUrl' 
          : downloadUrl;
      
      // Скачиваем файл
      final response = await http.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        // Получаем директорию для сохранения
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';
        final file = File(filePath);
        
        // Сохраняем файл
        await file.writeAsBytes(response.bodyBytes);
        
        // Закрываем индикатор загрузки
        if (mounted) {
          Navigator.of(context).pop();
        }
        
        // Проверяем тип файла
        final isExcel = filename.endsWith('.xlsx') || filename.endsWith('.xls');
        final isCsv = filename.endsWith('.csv');
        
        if (isExcel || isCsv) {
          // Парсим и отображаем Excel/CSV файл
          final bytes = response.bodyBytes;
          if (isExcel) {
            _showExcelViewer(bytes, filename);
          } else {
            _showCsvViewer(bytes, filename);
          }
        } else {
          // Для других типов файлов сразу открываем диалог "Поделиться"
          await Share.shareXFiles(
            [XFile(filePath)],
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при скачивании файла')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
  
  // Отображение Excel файла
  void _showExcelViewer(List<int> bytes, String filename) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];
      
      if (sheet == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось прочитать Excel файл')),
          );
        }
        return;
      }
      
      // Преобразуем данные в список строк
      final List<List<String>> rows = [];
      for (var row in sheet.rows) {
        final List<String> rowData = [];
        for (var cell in row) {
          rowData.add(cell?.value?.toString() ?? '');
        }
        rows.add(rowData);
      }
      
      // Получаем путь к файлу для кнопки "Поделиться"
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _FileViewerScreen(
              filename: filename,
              rows: rows,
              filePath: filePath,
            ),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при чтении Excel: $e')),
        );
      }
    }
  }
  
  // Отображение CSV файла
  void _showCsvViewer(List<int> bytes, String filename) async {
    try {
      final csvString = utf8.decode(bytes);
      final rows = const CsvToListConverter().convert(csvString);
      
      // Преобразуем в List<List<String>>
      final List<List<String>> stringRows = rows.map((row) {
        return row.map((cell) => cell.toString()).toList();
      }).toList();
      
      // Получаем путь к файлу для кнопки "Поделиться"
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _FileViewerScreen(
              filename: filename,
              rows: stringRows,
              filePath: filePath,
            ),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при чтении CSV: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ).then((_) {
          // Скрываем кнопку после прокрутки
          if (mounted) {
            setState(() {
              _showScrollDownButton = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget conversationArea;
    if (_hasConversation) {
      // Если идет загрузка чата по conversationId, показываем индикатор загрузки
      if (_isLoadingChat && _messages.isEmpty) {
        conversationArea = Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.darkPrimaryText : AppColors.textPrimary,
          ),
        );
      } else {
      conversationArea = Padding(
        padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
        child: _messages.isEmpty
            ? const SizedBox.shrink()
            : ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final bool isLast = index == _messages.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : scaleHeight(24),
                    ),
                    child: _MessageBubble(
                      message: message,
                      designWidth: _designWidth,
                      designHeight: _designHeight,
                      accentColor: _accentColor,
                      onCopy: _showCopyToastOnce,
                      onDownloadFile: _downloadAndShareFile,
                    ),
                  );
                },
              ),
      );
      }
    } else {
      conversationArea = SingleChildScrollView(
        padding: EdgeInsets.only(bottom: scaleHeight(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/bot.png',
                width: scaleWidth(105),
                height: scaleHeight(157),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: scaleHeight(14)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleWidth(25)),
              child: Container(
                width: double.infinity,
                height: scaleHeight(48),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkBackgroundCard : Colors.white,
                  borderRadius: BorderRadius.circular(scaleHeight(16)),
                ),
                padding: EdgeInsets.symmetric(horizontal: scaleWidth(16)),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/icon_stars.svg',
                      width: scaleWidth(16),
                      height: scaleHeight(16),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: scaleWidth(8)),
                    Expanded(
                      child: Text(
                        l.aiGreeting,
                        style: AppTextStyle.bodyTextMedium(
                          scaleHeight(15),
                          color: isDark
                              ? AppColors.white
                              : _primaryTextColor,
                        ).copyWith(height: 24 / 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: scaleHeight(24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleWidth(25)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkBackgroundCard : Colors.white,
                  borderRadius: BorderRadius.circular(scaleHeight(12)),
                ),
                padding: EdgeInsets.fromLTRB(
                  scaleWidth(16),
                  scaleHeight(24),
                  scaleWidth(16),
                  scaleHeight(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon_stars.svg',
                          width: scaleWidth(16),
                          height: scaleHeight(16),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: scaleWidth(8)),
                        Expanded(
                          child: Text(
                            l.aiSuggestionsTitle,
                            style: AppTextStyle.bodyTextMedium(
                              scaleHeight(16),
                              color: isDark
                                  ? AppColors.white
                                  : _primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleHeight(24)),
                    Wrap(
                      spacing: scaleWidth(12),
                      runSpacing: scaleHeight(12),
                      children: <String>[
                        l.aiSuggestion1,
                        l.aiSuggestion2,
                        l.aiSuggestion3,
                        l.aiSuggestion4,
                        l.aiSuggestion5,
                        l.aiSuggestion6,
                      ]
                          .map(
                            (chip) => _SuggestionChip(
                              text: chip,
                              designWidth: _designWidth,
                              designHeight: _designHeight,
                              accentColor: _accentColor,
                              primaryTextColor: _primaryTextColor,
                              onTap: () {
                                _inputController.text = TextUtils.safeText(chip);
                                _sendMessage();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: scaleHeight(13)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Smile AI',
                            style: AppTextStyle.screenTitleMedium(
                              scaleHeight(20),
                              color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              _showChatMenuOverlay();
                            },
                            child: SvgPicture.asset(
                              isDark
                                  ? 'assets/icons/dark/icon_mes_dark.svg'
                                  : 'assets/icons/light/icon_mes.svg',
                          width: scaleWidth(24),
                          height: scaleHeight(24),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleHeight(12)),
              Container(
                width: double.infinity,
                height: 1,
                    color: AppColors.textDarkGrey,
              ),
              SizedBox(height: scaleHeight(12)),
              Expanded(child: conversationArea),
              SizedBox(height: scaleHeight(12)),
              Padding(
                padding: EdgeInsets.only(
                  left: scaleWidth(25),
                  right: scaleWidth(25),
                  bottom: scaleHeight(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                      child: Container(
                          // Максимальная высота текстового поля (изменить здесь при необходимости)
                          constraints: BoxConstraints(
                            minHeight: scaleHeight(54),
                            maxHeight: scaleHeight(150), // МАКСИМАЛЬНАЯ ВЫСОТА: изменить scaleHeight(200) на нужное значение
                          ),
                        decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackgroundCard
                                  : AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(scaleHeight(12)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F18274B),
                              offset: Offset(0, 14),
                              blurRadius: 64,
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Color(0x1F18274B),
                              offset: Offset(0, 8),
                              blurRadius: 22,
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.only(
                          left: scaleWidth(16),
                          right: scaleWidth(15),
                            top: scaleHeight(16),
                            bottom: scaleHeight(16),
                        ),
                          child: _isListening
                              ? _buildRecordingUI(isDark, scaleWidth, scaleHeight)
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _isRecognizing
                                  ? _buildRecognizingText(isDark, scaleWidth, scaleHeight)
                                  : TextField(
                                      controller: _inputController,
                                      maxLines: null,
                                      minLines: 1,
                                      style: AppTextStyle.bodyTextMedium(
                                        scaleHeight(16),
                                        color: isDark
                                            ? AppColors.white
                                            : _primaryTextColor,
                                      ),
                                      cursorColor: _accentColor,
                                      decoration: InputDecoration(
                                        hintText: l.aiInputPlaceholder,
                                        hintStyle: AppTextStyle.bodyTextMedium(
                                          scaleHeight(16),
                                          color: isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.textDarkGrey,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      textInputAction: TextInputAction.newline,
                                      onSubmitted: (_) => _sendMessage(),
                                      enableInteractiveSelection: true,
                                      enableSuggestions: true,
                                      autocorrect: true,
                                    ),
                            ),
                                    GestureDetector(
                                      onTap: _startListening,
                                      child: SvgPicture.asset(
                                  'assets/icons/icon_mic.svg',
                              width: scaleWidth(24),
                              height: scaleHeight(24),
                              fit: BoxFit.contain,
                                      ),
                            ),
                          ],
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: scaleWidth(20)),
                    GestureDetector(
                      onTap: _isListening
                          ? _stopListening
                          : (_isTyping ? _stopGeneration : _sendMessage),
                      child: Container(
                        width: scaleWidth(54),
                        height: scaleHeight(54),
                        decoration: BoxDecoration(
                          color: _accentColor,
                              borderRadius:
                                  BorderRadius.circular(scaleHeight(50)),
                        ),
                        child: Center(
                          child: _isListening
                              ? Container(
                                  width: scaleWidth(18),
                                  height: scaleWidth(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      scaleWidth(2),
                                    ),
                                  ),
                                )
                              : _isTyping
                                  ? Container(
                                      width: scaleWidth(18),
                                      height: scaleWidth(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          scaleWidth(2),
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/icons/light/icon_teleg.png',
                            width: scaleWidth(24),
                            height: scaleHeight(24),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
          if (_showCopyToast)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.white : AppColors.black)
                      .withValues(alpha: isDark ? 0.8 : 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l.aiCopyToast,
                  style: AppTextStyle.bodyTextMedium(
                    16,
                    color: isDark ? AppColors.black : AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Кнопка прокрутки вниз - поверх всех элементов
          if (_showScrollDownButton && _hasConversation)
            Positioned(
              bottom: scaleHeight(86), // Отступ от текстового поля (54 высота поля + 20 отступ снизу + 12 небольшой отступ, как между сообщениями и полем)
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _scrollToBottom();
                    },
                    borderRadius: BorderRadius.circular(scaleHeight(20)),
                    child: Container(
                      width: scaleWidth(40),
                      height: scaleHeight(40),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackgroundCard
                            : AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0x1F18274B),
                            offset: Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: isDark
                            ? AppColors.white
                            : _primaryTextColor,
                        size: scaleHeight(24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.text,
    required this.designWidth,
    required this.designHeight,
    required this.accentColor,
    required this.primaryTextColor,
    required this.onTap,
  });

  final String text;
  final double designWidth;
  final double designHeight;
  final Color accentColor;
  final Color primaryTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return InkWell(
      borderRadius: BorderRadius.circular(scaleHeight(20)),
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(10),
        vertical: scaleHeight(10),
      ),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackgroundCard : AppColors.white,
        borderRadius: BorderRadius.circular(scaleHeight(20)),
        border: Border.all(color: accentColor, width: 1),
      ),
      child: Text(
        text,
          style: AppTextStyle.bodyTextMedium(
            scaleHeight(14),
            color: isDark ? AppColors.white : primaryTextColor,
          ),
        ),
      ),
    );
  }
}

// Кастомный builder для горизонтальной линии
class _HorizontalRuleBuilder extends MarkdownElementBuilder {
  final Color lineColor;
  final double lineHeight;
  final double verticalPadding;
  final bool isFirstInMessage;

  _HorizontalRuleBuilder({
    required this.lineColor,
    this.lineHeight = 0.5,
    this.verticalPadding = 16,
    this.isFirstInMessage = false,
  });

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInMessage ? 0 : verticalPadding, // Убираем верхний отступ, если "---" в начале сообщения
        bottom: verticalPadding,
      ),
      child: Container(
        width: double.infinity,
        height: lineHeight,
        color: lineColor,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.designWidth,
    required this.designHeight,
    required this.accentColor,
    required this.onCopy,
    required this.onDownloadFile,
  });

  final ChatMessage message;
  final double designWidth;
  final double designHeight;
  final Color accentColor;
  final VoidCallback onCopy;
  final Future<void> Function(String downloadUrl, String filename) onDownloadFile;

  // Проверяет, начинается ли сообщение с горизонтальной линии (---)
  static bool _isMessageStartingWithHr(String text) {
    if (text.isEmpty) return false;
    // Убираем все пробелы, табы и переводы строк в начале
    final trimmed = text.trimLeft();
    // Проверяем, начинается ли с "---", "***" или "___" (markdown горизонтальные линии)
    // Также проверяем варианты с пробелами после дефисов
    final normalized = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    return normalized.startsWith('---') || 
           normalized.startsWith('***') || 
           normalized.startsWith('___') ||
           normalized.startsWith('- - -') ||
           normalized.startsWith('* * *') ||
           normalized.startsWith('_ _ _');
  }

  // Убирает горизонтальную линию (---) в начале сообщения
  static String _removeLeadingHr(String text) {
    if (text.isEmpty) return text;
    
    // Убираем все пробелы и переводы строк в начале
    final trimmed = text.trimLeft();
    
    // Проверяем, начинается ли с горизонтальной линии
    if (trimmed.startsWith('---') || 
        trimmed.startsWith('***') || 
        trimmed.startsWith('___')) {
      // Находим конец первой строки (до первого перевода строки)
      final firstLineEnd = trimmed.indexOf('\n');
      if (firstLineEnd != -1) {
        // Убираем первую строку с "---" и следующие пустые строки
        var result = trimmed.substring(firstLineEnd + 1);
        // Убираем все пустые строки в начале
        while (result.startsWith('\n') || result.startsWith('\r\n')) {
          result = result.replaceFirst(RegExp(r'^[\r\n]+'), '');
        }
        return result;
      } else {
        // Если это только "---" без текста после, возвращаем пустую строку
        return '';
      }
    }
    
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bubbleColor = message.isUser
        ? accentColor
        : (isDark ? AppColors.darkBackgroundCard : Colors.white);
    final BorderRadius borderRadius = message.isUser
        ? BorderRadius.only(
            topLeft: Radius.circular(scaleHeight(19)),
            topRight: Radius.circular(scaleHeight(19)),
            bottomLeft: Radius.circular(scaleHeight(19)),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(scaleHeight(19)),
            topRight: Radius.circular(scaleHeight(19)),
            bottomRight: Radius.circular(scaleHeight(19)),
          );

    final TextStyle textStyle = AppTextStyle.chatMessage(
      scaleHeight(16),
      color: message.isUser
          ? AppColors.white
          : (isDark ? AppColors.darkPrimaryText : AppColors.textPrimary),
      height: message.isUser ? 1 : 21 / 16,
    );

    final Widget bubble = Container(
      constraints: BoxConstraints(
        maxWidth: scaleWidth(message.isUser ? 255 : 308),
      ),
      padding: EdgeInsets.all(scaleHeight(15)),
      decoration: BoxDecoration(color: bubbleColor, borderRadius: borderRadius),
      child: message.isUser
          ? Text(TextUtils.safeText(message.text), style: textStyle)
          : message.isThinking
              ? _ThinkingIndicator(
                  baseColor: isDark ? AppColors.darkPrimaryText : AppColors.textPrimary,
                  isDark: isDark,
                  size: scaleHeight(20),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Файлы (если есть)
                    if (message.files != null && message.files!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: message.text.isNotEmpty ? scaleHeight(8) : 0,
                        ),
                        child: Wrap(
                          spacing: scaleWidth(8),
                          runSpacing: scaleHeight(8),
                          children: message.files!.map((file) {
                            return _buildFilePreview(file, isDark, scaleWidth, scaleHeight, onDownloadFile);
                          }).toList(),
                        ),
                      ),
                    // Текст сообщения
                    if (message.text.isNotEmpty)
                      MarkdownBody(
              data: _removeLeadingHr(TextUtils.safeText(message.text)),
              styleSheet: MarkdownStyleSheet(
                p: textStyle,
                strong: textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
                em: textStyle.copyWith(
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Montserrat',
                ),
                code: textStyle.copyWith(
                  fontFamily: 'Montserrat',
                  backgroundColor: isDark
                      ? AppColors.darkBackgroundMain
                      : AppColors.backgroundMain,
                ),
                codeblockDecoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackgroundMain
                      : AppColors.backgroundMain,
                  borderRadius: BorderRadius.circular(scaleHeight(8)),
                ),
                codeblockPadding: EdgeInsets.all(scaleHeight(12)),
                tableHead: textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
                tableBody: textStyle,
                tableBorder: TableBorder.all(
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.textSecondary,
                  width: 1,
                ),
                tableCellsPadding: EdgeInsets.all(scaleHeight(8)),
                h1: textStyle.copyWith(
                  fontSize: scaleHeight(24),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
                h2: textStyle.copyWith(
                  fontSize: scaleHeight(20),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
                h3: textStyle.copyWith(
                  fontSize: scaleHeight(18),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
                listBullet: textStyle,
                blockquote: textStyle.copyWith(
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Montserrat',
                ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.textSecondary,
                      width: 3,
                    ),
                  ),
                ),
                blockquotePadding: EdgeInsets.only(
                  left: scaleWidth(12),
                  top: scaleHeight(8),
                  bottom: scaleHeight(8),
                ),
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: message.isUser
                          ? AppColors.white
                          : (isDark ? AppColors.darkPrimaryText : AppColors.textPrimary),
                      width: 3,
                    ),
                  ),
                ),
              ),
              selectable: true,
              builders: <String, MarkdownElementBuilder>{
                'hr': _HorizontalRuleBuilder(
                  lineColor: message.isUser
                      ? AppColors.white
                      : (isDark ? AppColors.darkPrimaryText : AppColors.textPrimary),
                  lineHeight: 0.5,
                  verticalPadding: scaleHeight(16),
                  isFirstInMessage: _isMessageStartingWithHr(message.text),
                ),
              },
            ),
                  ],
            ),
    );

    if (message.isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bubble,
          if (!message.isThinking) ...[
          SizedBox(width: scaleWidth(10)),
          GestureDetector(
            onTap: () {
                Clipboard.setData(ClipboardData(text: TextUtils.safeText(message.text)));
              onCopy();
            },
            child: SvgPicture.asset(
              isDark
                  ? 'assets/icons/dark/icon_copy_dark.svg'
                  : 'assets/icons/light/icon_copy.svg',
              width: scaleWidth(20),
              height: scaleHeight(30),
              fit: BoxFit.contain,
            ),
          ),
          ],
        ],
      );
    }
  }
  
  // Функция для отображения превью файла
  Widget _buildFilePreview(
    Map<String, dynamic> file,
    bool isDark,
    double Function(double) scaleWidth,
    double Function(double) scaleHeight,
    Future<void> Function(String, String) onDownloadFile,
  ) {
    final filename = file['filename'] as String? ?? 'file';
    final mime = file['mime'] as String? ?? '';
    final downloadUrl = file['download_url'] as String? ?? '';
    
    // Определяем иконку по типу файла
    IconData fileIcon = Icons.insert_drive_file;
    if (mime.contains('excel') || mime.contains('spreadsheet') || filename.endsWith('.xlsx') || filename.endsWith('.xls')) {
      fileIcon = Icons.table_chart;
    } else if (mime.contains('csv') || filename.endsWith('.csv')) {
      fileIcon = Icons.table_view;
    } else if (mime.contains('pdf') || filename.endsWith('.pdf')) {
      fileIcon = Icons.picture_as_pdf;
    } else if (mime.contains('word') || filename.endsWith('.doc') || filename.endsWith('.docx')) {
      fileIcon = Icons.description;
    }
    
    return GestureDetector(
      onTap: () => onDownloadFile(downloadUrl, filename),
      child: Container(
        width: scaleHeight(100),
        height: scaleHeight(100),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.darkBackgroundMain 
              : AppColors.backgroundMain,
          borderRadius: BorderRadius.circular(scaleHeight(12)),
          border: Border.all(
            color: isDark 
                ? AppColors.darkSecondaryText 
                : AppColors.textSecondary,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              fileIcon,
              size: scaleWidth(40),
              color: isDark 
                  ? AppColors.darkPrimaryText 
                  : AppColors.textPrimary,
            ),
            SizedBox(height: scaleHeight(4)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleWidth(4)),
              child: Text(
                filename,
                style: AppTextStyle.chatMessage(
                  scaleHeight(10),
                  color: isDark 
                      ? AppColors.darkSecondaryText 
                      : AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isThinking = false,
    this.files,
  });

  final String text;
  final bool isUser;
  final bool isThinking; // Флаг для состояния "думает"
  final List<Map<String, dynamic>>? files; // Файлы из ответа AI (Excel, CSV и т.д.)
}

class ChatHistory {
  ChatHistory({
    required this.id,
    required this.title,
    required this.messages,
    this.conversationId,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  String? conversationId;
}

class _ChatMenuDrawer extends StatelessWidget {
  const _ChatMenuDrawer({
    required this.designWidth,
    required this.designHeight,
    required this.onClose,
    required this.onNewChat,
    required this.chatHistory,
    this.selectedChatIndex,
    this.onChatSelected,
    this.onContextMenuClosed,
    this.editingChatIndex,
    this.renameControllers,
    this.onChatTap,
    this.onDeleteChat,
    this.onRenameChat,
    this.onSaveRename,
    this.onCancelRename,
  });

  final double designWidth;
  final double designHeight;
  final VoidCallback onClose;
  final VoidCallback onNewChat;
  final List<ChatHistory> chatHistory;
  final int? selectedChatIndex;
  final ValueChanged<int>? onChatSelected;
  final VoidCallback? onContextMenuClosed;
  final int? editingChatIndex;
  final Map<int, TextEditingController>? renameControllers;
  final ValueChanged<int>? onChatTap;
  final ValueChanged<int>? onDeleteChat;
  final ValueChanged<int>? onRenameChat;
  final ValueChanged<int>? onSaveRename;
  final VoidCallback? onCancelRename;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              // Закрываем контекстное меню при клике на основное меню
              if (selectedChatIndex != null && onContextMenuClosed != null) {
                onContextMenuClosed!();
              }
            },
            child: Container(
              width: scaleWidth(291),
              height: MediaQuery.of(context).size.height, // Полная высота экрана для перекрытия нав бара
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackgroundCard : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(scaleHeight(30)),
                  bottomLeft: Radius.circular(scaleHeight(30)),
                ),
              ),
              padding: EdgeInsets.only(
                left: scaleWidth(18),
                right: scaleWidth(18),
                top: scaleHeight(75),
                bottom: scaleHeight(26),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Крестик слева вверху
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: onClose,
                            child: Icon(
                              Icons.close,
                              size: scaleWidth(24),
                              color: isDark
                                  ? AppColors.white
                                  : const Color(0xFF201D2F),
                            ),
                          ),
                          // icon_mes.svg справа вверху
                          SvgPicture.asset(
                            isDark
                                ? 'assets/icons/dark/icon_mes_dark.svg'
                                : 'assets/icons/light/icon_mes.svg',
                            width: scaleWidth(24),
                            height: scaleHeight(24),
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      SizedBox(height: scaleHeight(23)),
                      // Новый чат - текст справа, иконка слева от текста
                      GestureDetector(
                        onTap: onNewChat,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.chatMenuNewChat,
                                style: AppTextStyle.screenTitle(
                                  scaleHeight(16),
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.black,
                                ).copyWith(
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              SizedBox(width: scaleWidth(12)),
                              SvgPicture.asset(
                                isDark
                                    ? 'assets/icons/dark/icon_new_chat.svg'
                                    : 'assets/icons/light/icon_new_chat.svg',
                                width: scaleWidth(24),
                                height: scaleHeight(24),
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: scaleHeight(28)),
                      // Заголовок "Чаты"
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          l.chatMenuChats,
                          style: AppTextStyle.screenTitle(
                            scaleHeight(20),
                            color: isDark
                                ? AppColors.white
                                : AppColors.black,
                          ).copyWith(
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      SizedBox(height: scaleHeight(20)),
                      // Список чатов
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: chatHistory.length,
                          itemBuilder: (context, index) {
                            final isEditing = editingChatIndex == index;
                            final controller = renameControllers?[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                top: index == 0 ? 0 : scaleHeight(20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: isEditing && controller != null
                                        ? Material(
                                            color: Colors.transparent,
                                            child: Focus(
                                              onFocusChange: (hasFocus) {
                                                if (!hasFocus && onSaveRename != null) {
                                                  onSaveRename!(index);
                                                }
                                              },
                                              child: TextField(
                                                controller: controller,
                                                style: AppTextStyle.screenTitle(
                                                  scaleHeight(15),
                                                  color: isDark
                                                      ? AppColors.white
                                                      : const Color(0xFF5B5B5B),
                                                ).copyWith(
                                                  decoration: TextDecoration.none,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                autofocus: true,
                                                onSubmitted: (value) {
                                                  if (onSaveRename != null) {
                                                    onSaveRename!(index);
                                                  }
                                                },
                                                onEditingComplete: () {
                                                  if (onSaveRename != null) {
                                                    onSaveRename!(index);
                                                  }
                                                },
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              if (onChatTap != null) {
                                                onChatTap!(index);
                                              }
                                            },
                                            child: Text(
                                              _AiScreenState._stripMarkdown(chatHistory[index].title),
                                              style: AppTextStyle.screenTitle(
                                                scaleHeight(15),
                                                color: isDark
                                                    ? AppColors.white
                                                    : const Color(0xFF5B5B5B),
                                              ).copyWith(
                                                decoration: TextDecoration.none,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: scaleWidth(12)),
                                  GestureDetector(
                                    onTap: () {
                                      if (onChatSelected != null) {
                                        onChatSelected!(index);
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      isDark
                                          ? 'assets/icons/dark/icon_dots.svg'
                                          : 'assets/icons/light/icon_dots.svg',
                                      width: scaleWidth(24),
                                      height: scaleHeight(24),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Контекстное меню - позиционируется под dots.svg
                  if (selectedChatIndex != null)
                    Builder(
                      builder: (context) {
                        // Вычисляем позицию: отступ сверху меню + заголовок + отступы + позиция чата
                        // dots.svg находится на right: 18px (padding контейнера)
                        // Правый угол меню должен быть прямо под правым краем dots.svg без отступов
                        // Высота каждого элемента чата: padding top (0 для первого, 20 для остальных) + высота Row с иконкой
                        final chatItemTopPadding = selectedChatIndex == 0 ? 0 : scaleHeight(20);
                        // Вычисляем позицию начала строки с чатом
                        // Убираем отступ после "Чаты", так как он уже есть в коде
                        final chatRowTop = scaleHeight(75) + // padding top
                            scaleHeight(24) + // крестик/icon_mes
                            scaleHeight(23) + // отступ после крестика
                            scaleHeight(24) + // "Новый чат" строка
                            scaleHeight(28) + // отступ после "Новый чат"
                            scaleHeight(20) + // "Чаты" заголовок
                            chatItemTopPadding + // отступ сверху для элемента чата (0 для первого, 20 для остальных)
                            (selectedChatIndex! * scaleHeight(44)); // позиция чата (отступ 20 + высота строки ~24)
                        final topOffset = chatRowTop - scaleHeight(30);
                        return Positioned(
                          right: scaleWidth(18), // правый край меню совпадает с правым краем dots.svg
                          top: topOffset, // меню начинается сразу под нижней границей иконки
                          child: GestureDetector(
                            onTap: () {}, // Предотвращаем закрытие при клике на меню
                            child: _ChatContextMenu(
                              designWidth: designWidth,
                              designHeight: designHeight,
                              chatIndex: selectedChatIndex!,
                              onClose: () {
                                if (onContextMenuClosed != null) {
                                  onContextMenuClosed!();
                                }
                              },
                              onDelete: () {
                                if (onDeleteChat != null) {
                                  onDeleteChat!(selectedChatIndex!);
                                }
                                if (onContextMenuClosed != null) {
                                  onContextMenuClosed!();
                                }
                              },
                              onRename: () {
                                if (onRenameChat != null) {
                                  onRenameChat!(selectedChatIndex!);
                                }
                                if (onContextMenuClosed != null) {
                                  onContextMenuClosed!();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatContextMenu extends StatelessWidget {
  const _ChatContextMenu({
    required this.designWidth,
    required this.designHeight,
    required this.onClose,
    required this.chatIndex,
    this.onDelete,
    this.onRename,
  });

  final double designWidth;
  final double designHeight;
  final VoidCallback onClose;
  final int chatIndex;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Container(
      width: scaleWidth(160),
      constraints: BoxConstraints(
        minHeight: scaleHeight(73),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackgroundCard
            : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(scaleHeight(15)),
        border: Border.all(
          color: isDark ? AppColors.white : AppColors.black,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(scaleWidth(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Переименовать
          _ContextMenuItem(
            iconPath: isDark
                ? 'assets/icons/dark/icon_rename.svg'
                : 'assets/icons/light/icon_rename.svg',
            text: l.chatMenuRename,
            textColor: isDark
                ? AppColors.white
                : const Color(0xFF5B5B5B),
            designWidth: designWidth,
            designHeight: designHeight,
            onTap: () {
              if (onRename != null) {
                onRename!();
              } else {
                onClose();
              }
            },
          ),
          // Удалить
          _ContextMenuItem(
            iconPath: 'assets/icons/icon_delete.svg',
            text: l.chatMenuDelete,
            textColor: const Color(0xFF76090B),
            designWidth: designWidth,
            designHeight: designHeight,
            onTap: () {
              if (onDelete != null) {
                onDelete!();
              } else {
                onClose();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.iconPath,
    required this.text,
    required this.textColor,
    required this.designWidth,
    required this.designHeight,
    required this.onTap,
  });

  final String iconPath;
  final String text;
  final Color textColor;
  final double designWidth;
  final double designHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: scaleHeight(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: scaleWidth(20),
              height: scaleHeight(20),
              fit: BoxFit.contain,
            ),
            SizedBox(width: scaleWidth(6)),
            Text(
              text,
              style: AppTextStyle.screenTitle(
                scaleHeight(13),
                color: textColor,
              ).copyWith(
                decoration: TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// Виджет мерцающего круга (как в ChatGPT)
class _ThinkingIndicator extends StatefulWidget {
  const _ThinkingIndicator({
    required this.baseColor,
    required this.isDark,
    required this.size,
  });

  final Color baseColor;
  final bool isDark;
  final double size;

  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Используем синусоидальную функцию для плавного перехода туда-обратно
        final progress = _controller.value;
        Color currentColor;
        
        if (widget.isDark) {
          // Темная тема: серый -> белый -> серый
          final grayColor = widget.baseColor.withValues(alpha: 0.4);
          final whiteColor = AppColors.white;
          // Синусоида для плавного перехода: 0 -> 1 -> 0
          final t = (math.sin(progress * 2 * math.pi) + 1) / 2;
          currentColor = Color.lerp(grayColor, whiteColor, t)!;
        } else {
          // Светлая тема: светлый -> темный -> светлый
          final lightColor = widget.baseColor.withValues(alpha: 0.3);
          final darkColor = widget.baseColor;
          // Синусоида для плавного перехода: 0 -> 1 -> 0
          final t = (math.sin(progress * 2 * math.pi) + 1) / 2;
          currentColor = Color.lerp(lightColor, darkColor, t)!;
        }
        
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: currentColor,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// Виджет для анимации текста "Распознание голоса" с точками
class _RecognizingTextAnimation extends StatefulWidget {
  final String baseText;
  final bool isDark;
  final double Function(double) scaleWidth;
  final double Function(double) scaleHeight;

  const _RecognizingTextAnimation({
    required this.baseText,
    required this.isDark,
    required this.scaleWidth,
    required this.scaleHeight,
  });

  @override
  State<_RecognizingTextAnimation> createState() => _RecognizingTextAnimationState();
}

class _RecognizingTextAnimationState extends State<_RecognizingTextAnimation> {
  int _dotCount = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _dotCount = (_dotCount + 1) % 4; // 0, 1, 2, 3, затем снова 0
      });
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    final text = '${widget.baseText}$dots';
    
    return Text(
      text,
      style: AppTextStyle.bodyTextMedium(
        widget.scaleHeight(16),
        color: widget.isDark ? AppColors.white : AppColors.primaryText,
      ),
    );
  }
}

// Полноэкранный экран для отображения Excel/CSV файлов
class _FileViewerScreen extends StatefulWidget {
  const _FileViewerScreen({
    required this.filename,
    required this.rows,
    required this.filePath,
  });

  final String filename;
  final List<List<String>> rows;
  final String filePath;

  @override
  State<_FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<_FileViewerScreen> {
  @override
  void initState() {
    super.initState();
    // Запрещаем поворот экрана - оставляем только портретную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // Возвращаем только портретную ориентацию при закрытии
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    const double designWidth = 428;
    const double designHeight = 926;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;
    
    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    // Определяем максимальную ширину колонки для лучшего отображения
    final maxColumnWidth = size.width * 0.3;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.darkPrimaryText : AppColors.textPrimary,
            size: scaleWidth(24),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.filename,
          style: AppTextStyle.chatMessage(
            scaleHeight(18),
            color: isDark ? AppColors.darkPrimaryText : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: widget.rows.isEmpty
          ? Center(
              child: Text(
                'Файл пуст',
                style: AppTextStyle.chatMessage(
                  scaleHeight(16),
                  color: isDark ? AppColors.darkSecondaryText : AppColors.textSecondary,
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(scaleHeight(16)),
                    child: Table(
                      border: TableBorder.all(
                        color: isDark ? AppColors.darkSecondaryText : AppColors.textSecondary,
                        width: 1,
                      ),
                      columnWidths: widget.rows.isNotEmpty
                          ? {
                              for (var index in List.generate(
                                widget.rows[0].length,
                                (index) => index,
                              ))
                                index: FixedColumnWidth(
                                  math.min(maxColumnWidth, constraints.maxWidth / widget.rows[0].length),
                                ),
                            }
                          : null,
                      children: widget.rows.asMap().entries.map((entry) {
                        final index = entry.key;
                        final row = entry.value;
                        return TableRow(
                          decoration: index == 0
                              ? BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkBackgroundCard
                                      : AppColors.backgroundMain,
                                )
                              : null,
                          children: row.map((cell) {
                            return Container(
                              constraints: BoxConstraints(
                                maxWidth: maxColumnWidth,
                              ),
                              padding: EdgeInsets.all(scaleHeight(8)),
                              child: Text(
                                cell,
                                style: AppTextStyle.chatMessage(
                                  scaleHeight(12),
                                  color: isDark ? AppColors.darkPrimaryText : AppColors.textPrimary,
                                ).copyWith(
                                  fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _shareFile(context),
        backgroundColor: isDark ? AppColors.darkBackgroundCard : AppColors.accentRed,
        child: Icon(
          Icons.share,
          color: AppColors.white,
          size: scaleWidth(24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      
      // Проверяем, что файл существует
      final file = File(widget.filePath);
      final fileExists = await file.exists();
      
      if (!fileExists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Файл не найден')),
          );
        }
        return;
      }

      // Используем try-catch для обработки ошибок плагина
      if (kIsWeb) {
        // Для веб используем другой метод
        await Share.share(widget.filename);
      } else {
        
        // Для iOS нужно указать sharePositionOrigin
        if (Platform.isIOS) {
          try {
            if (!context.mounted) return;
            // Получаем размер экрана для правильного позиционирования
            final size = MediaQuery.of(context).size;
            if (!context.mounted) return;
            final box = context.findRenderObject() as RenderBox?;
            final position = box?.localToGlobal(Offset.zero) ?? Offset.zero;
            
            
            // Используем shareXFiles с sharePositionOrigin для iOS
            await Share.shareXFiles(
              [XFile(widget.filePath)],
              sharePositionOrigin: Rect.fromLTWH(
                position.dx,
                position.dy,
                size.width,
                size.height,
              ),
            );
          } catch (e) {
            
            // Fallback: пробуем без sharePositionOrigin
            try {
              await Share.shareXFiles(
                [XFile(widget.filePath)],
              );
            } catch (e2) {
              
              // Последний fallback: обычный share
              if (context.mounted) {
                await Share.share(
                  'Файл: ${widget.filename}',
                );
              }
            }
          }
        } else {
          // Для Android
          try {
            await Share.shareXFiles(
              [XFile(widget.filePath)],
            );
          } catch (e) {
            
            // Fallback для Android
            if (context.mounted) {
              await Share.share(
                'Файл: ${widget.filename}',
              );
            }
          }
        }
      }
    } catch (e) {
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при открытии диалога "Поделиться": $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
