import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({
    super.key,
    this.autoGenerateText,
    this.editText,
    this.onTextSaved,
    this.category,
  });

  final String? autoGenerateText;
  final String? editText;
  final ValueChanged<String>? onTextSaved;
  final String? category;

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
  
  // История чатов
  final List<ChatHistory> _chatHistory = [];
  int? _currentChatId;
  int? _editingChatIndex;
  final Map<int, TextEditingController> _renameControllers = {};
  String? _currentCategory;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    // Сохраняем категорию если она передана
    if (widget.category != null) {
      _currentCategory = widget.category;
    }
    
    // Если передан текст для редактирования, загружаем его в поле ввода
    if (widget.editText != null) {
      _inputController.text = widget.editText!;
      _isEditMode = true;
    }
    // Если передан текст для автогенерации, запускаем генерацию
    else if (widget.autoGenerateText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessageWithApi(widget.autoGenerateText!, category: widget.category);
      });
    }
  }

  Future<void> _sendMessageWithApi(String message, {String? category}) async {
    // Получаем токен
    await AuthService.instance.init();
    final token = AuthService.instance.getToken();
    
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка: токен не найден. Пожалуйста, войдите в аккаунт.'),
          backgroundColor: AppColors.textError,
        ),
      );
      return;
    }

    // Получаем conversation_id из текущего чата
    String? conversationId;
    if (_currentChatId != null) {
      final chatIndex = _chatHistory.indexWhere((chat) => chat.id == _currentChatId.toString());
      if (chatIndex != -1) {
        conversationId = _chatHistory[chatIndex].conversationId;
      }
    }

    // Добавляем сообщение пользователя
    setState(() {
      _hasConversation = true;
      _messages.add(ChatMessage(text: message, isUser: true));
      _isTyping = true;
      _currentTypingIndex = 0;
      _messages.add(const ChatMessage(text: '', isUser: false));
    });

    _scrollToBottom();

    try {
      // Отправляем запрос на API
      final result = await ApiService.instance.sendMessage(
        userId: token,
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
          ));
        });
        _scrollToBottom();
        return;
      }

      // Успешный ответ
      final responseText = result['response'] as String? ?? '';
      final newConversationId = result['conversation_id'] as String?;

      // Сохраняем conversation_id в текущий чат
      if (newConversationId != null && newConversationId.isNotEmpty) {
        if (_currentChatId != null) {
          final chatIndex = _chatHistory.indexWhere((chat) => chat.id == _currentChatId.toString());
          if (chatIndex != -1) {
            _chatHistory[chatIndex].conversationId = newConversationId;
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
            );
            _isTyping = false;
            // Сохраняем чат после завершения генерации
            _saveCurrentChat();
            // Отправляем уведомление о завершении генерации
            NotificationService.instance.showAiMessageNotification(responseText);
          } else {
            _currentTypingIndex += 1;
            _messages[_messages.length - 1] = ChatMessage(
              text: responseText.substring(0, _currentTypingIndex.toInt()),
              isUser: false,
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
        ));
      });
      _scrollToBottom();
    }
  }

  void _showChatMenuOverlay() {
    if (_chatMenuOverlay != null) {
      _chatMenuOverlay!.remove();
      _chatMenuOverlay = null;
    }
    
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
    _chatMenuOverlay?.remove();
    _inputController.dispose();
    _scrollController.dispose();
    for (var controller in _renameControllers.values) {
      controller.dispose();
    }
    _renameControllers.clear();
    super.dispose();
  }
  
  void _openChat(int index) {
    if (index >= 0 && index < _chatHistory.length) {
      _saveCurrentChat(); // Сохраняем текущий чат перед открытием другого
      final chat = _chatHistory[index];
      setState(() {
        _currentChatId = int.tryParse(chat.id);
        _messages.clear();
        _messages.addAll(chat.messages);
        _hasConversation = true;
        _hideChatMenuOverlay();
      });
      _scrollToBottom();
    }
  }
  
  void _deleteChat(int index) {
    if (index >= 0 && index < _chatHistory.length) {
      setState(() {
        if (_currentChatId != null && _chatHistory[index].id == _currentChatId.toString()) {
          _currentChatId = null;
          _messages.clear();
          _hasConversation = false;
        }
        // Удаляем контроллер для удаляемого чата
        if (_renameControllers.containsKey(index)) {
          _renameControllers[index]?.dispose();
          _renameControllers.remove(index);
        }
        // Обновляем индексы для контроллеров
        final newControllers = <int, TextEditingController>{};
        for (var entry in _renameControllers.entries) {
          if (entry.key > index) {
            newControllers[entry.key - 1] = entry.value;
          } else if (entry.key < index) {
            newControllers[entry.key] = entry.value;
          }
        }
        _renameControllers.clear();
        _renameControllers.addAll(newControllers);
        // Сбрасываем editingChatIndex, если удаляемый чат редактировался
        if (_editingChatIndex == index) {
          _editingChatIndex = null;
        } else if (_editingChatIndex != null && _editingChatIndex! > index) {
          _editingChatIndex = _editingChatIndex! - 1;
        }
        _chatHistory.removeAt(index);
      });
      // Обновляем Overlay после удаления
      if (_chatMenuOverlay != null) {
        _chatMenuOverlay!.markNeedsBuild();
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
  
  void _saveRenamedChat(int index) {
    if (index >= 0 && index < _chatHistory.length && _renameControllers.containsKey(index)) {
      final newTitle = _renameControllers[index]!.text.trim();
      if (newTitle.isNotEmpty) {
        setState(() {
          _chatHistory[index] = ChatHistory(
            id: _chatHistory[index].id,
            title: newTitle,
            messages: _chatHistory[index].messages,
          );
          _editingChatIndex = null;
        });
        // Обновляем Overlay после сохранения
        if (_chatMenuOverlay != null) {
          _chatMenuOverlay!.markNeedsBuild();
        }
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
      final chatIndex = _chatHistory.indexWhere((chat) => chat.id == _currentChatId.toString());
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

  void _sendMessage() {
    final text = _inputController.text.trim();
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
      final newChat = ChatHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text.length > 30 ? '${text.substring(0, 30)}...' : text,
        messages: [],
      );
      _chatHistory.insert(0, newChat);
      _currentChatId = int.tryParse(newChat.id);
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
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
                    ),
                  );
                },
              ),
      );
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
                                _inputController.text = chip;
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
                  SizedBox(height: scaleHeight(24)),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppColors.textDarkGrey,
                  ),
                  SizedBox(height: scaleHeight(24)),
                  Expanded(child: conversationArea),
                  SizedBox(height: scaleHeight(24)),
                  if (_hasConversation && _isTyping) ...[
                    Center(
                      child: GestureDetector(
                        onTap: _stopGeneration,
                        child: Container(
                          width: scaleWidth(255),
                          height: scaleHeight(44),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.borderDefault),
                            borderRadius:
                                BorderRadius.circular(scaleHeight(12)),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: scaleWidth(16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: scaleWidth(18),
                                height: scaleWidth(18),
                                decoration: BoxDecoration(
                                  color: _accentColor,
                                  borderRadius: BorderRadius.circular(
                                    scaleWidth(2),
                                  ),
                                ),
                              ),
                              SizedBox(width: scaleWidth(11)),
                              Flexible(
                                child: Text(
                                  l.aiStopGeneration,
                                  style: AppTextStyle.bodyTextMedium(
                                    scaleHeight(14),
                                    color: theme.colorScheme.onSurface,
                                  ).copyWith(height: 20 / 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: scaleHeight(24)),
                  ],
                  Padding(
                    padding: EdgeInsets.only(
                      left: scaleWidth(25),
                      right: scaleWidth(25),
                      bottom: scaleHeight(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: scaleHeight(54),
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
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _inputController,
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
                                    ),
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                    enableInteractiveSelection: true,
                                    enableSuggestions: true,
                                    autocorrect: true,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/icons/icon_mic.svg',
                                  width: scaleWidth(24),
                                  height: scaleHeight(24),
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: scaleWidth(20)),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: scaleWidth(54),
                            height: scaleHeight(54),
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius:
                                  BorderRadius.circular(scaleHeight(50)),
                            ),
                            child: Center(
                              child: Image.asset(
                                isDark
                                    ? 'assets/icons/dark/icon_teleg_dark.png'
                                    : 'assets/icons/light/icon_teleg.png',
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.designWidth,
    required this.designHeight,
    required this.accentColor,
    required this.onCopy,
  });

  final ChatMessage message;
  final double designWidth;
  final double designHeight;
  final Color accentColor;
  final VoidCallback onCopy;

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
          ? Text(message.text, style: textStyle)
          : MarkdownBody(
              data: message.text,
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
              ),
              selectable: true,
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
          SizedBox(width: scaleWidth(10)),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.text));
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
      );
    }
  }
}

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
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
                                              chatHistory[index].title,
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
