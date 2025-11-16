import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../settings/style.dart';
import '../services/notification_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({
    super.key,
    this.autoGenerateText,
    this.editText,
    this.onTextSaved,
  });

  final String? autoGenerateText;
  final String? editText;
  final ValueChanged<String>? onTextSaved;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  static const Color _backgroundColor = Color(0xFFF7F7F7);
  static const Color _primaryTextColor = Color(0xFF201D2F);
  static const Color _accentColor = Color(0xFFAD2023);
  static const String _assistantReply =
      'Хорошо. цель — стабильный доход или масштаб? от этого зависит стратегия: быстрые продажи или долгосрочный бренд.';
  static const List<String> _suggestions = <String>[
    'Привет',
    'Как дела?',
    'Что умеешь?',
    'Спроси меня',
    'Помоги',
    'Совет',
  ];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _hasConversation = false;
  Timer? _typingTimer;
  double _currentTypingIndex = 0;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    // Если передан текст для редактирования, загружаем его в поле ввода
    if (widget.editText != null) {
      _inputController.text = widget.editText!;
      _isEditMode = true;
    }
    // Если передан текст для автогенерации, запускаем генерацию
    else if (widget.autoGenerateText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoGeneration(widget.autoGenerateText!);
      });
    }
  }

  void _startAutoGeneration(String text) {
    setState(() {
      _hasConversation = true;
      _isTyping = true;
      _currentTypingIndex = 0;
      _messages.add(_ChatMessage(text: '', isUser: false));
    });

    _scrollToBottom();

    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_currentTypingIndex >= text.length) {
          timer.cancel();
          _messages[_messages.length - 1] = _ChatMessage(
            text: text,
            isUser: false,
          );
          _isTyping = false;
          // Отправляем уведомление о завершении генерации
          NotificationService.instance.showAiMessageNotification(text);
        } else {
          _currentTypingIndex += 1;
          _messages[_messages.length - 1] = _ChatMessage(
            text: text.substring(0, _currentTypingIndex.toInt()),
            isUser: false,
          );
        }
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      // После сохранения продолжаем обычный чат
      FocusScope.of(context).unfocus();
      setState(() {
        _hasConversation = true;
        _messages.add(_ChatMessage(text: text, isUser: true));
        _isTyping = true;
        _currentTypingIndex = 0;
        _messages.add(const _ChatMessage(text: '', isUser: false));
        _inputController.clear();
      });

      _scrollToBottom();

      _typingTimer?.cancel();
      _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        setState(() {
          if (_currentTypingIndex >= _assistantReply.length) {
            timer.cancel();
            _messages[_messages.length - 1] = _ChatMessage(
              text: _assistantReply,
              isUser: false,
            );
            _isTyping = false;
            // Отправляем уведомление о завершении генерации
            NotificationService.instance.showAiMessageNotification(
              _assistantReply,
            );
          } else {
            _currentTypingIndex += 1;
            _messages[_messages.length - 1] = _ChatMessage(
              text: _assistantReply.substring(0, _currentTypingIndex.toInt()),
              isUser: false,
            );
          }
        });
        _scrollToBottom();
      });
      return;
    }

    // Обычная отправка сообщения
    FocusScope.of(context).unfocus();
    setState(() {
      _hasConversation = true;
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _currentTypingIndex = 0;
      _messages.add(const _ChatMessage(text: '', isUser: false));
      _inputController.clear();
    });

    _scrollToBottom();

    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_currentTypingIndex >= _assistantReply.length) {
          timer.cancel();
          _messages[_messages.length - 1] = _ChatMessage(
            text: _assistantReply,
            isUser: false,
          );
          _isTyping = false;
          // Отправляем уведомление о завершении генерации
          NotificationService.instance.showAiMessageNotification(
            _assistantReply,
          );
        } else {
          _currentTypingIndex += 1;
          _messages[_messages.length - 1] = _ChatMessage(
            text: _assistantReply.substring(0, _currentTypingIndex.toInt()),
            isUser: false,
          );
        }
      });
      _scrollToBottom();
    });
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
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

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
                  color: Colors.white,
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
                        'Привет, ты можешь спросить меня',
                        style: AppTextStyle.bodyTextMedium(
                          scaleHeight(15),
                          color: _primaryTextColor,
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
                  color: Colors.white,
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
                            'Может эти слова тебе помогут...',
                            style: AppTextStyle.bodyTextMedium(
                              scaleHeight(16),
                              color: _primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scaleHeight(24)),
                    Wrap(
                      spacing: scaleWidth(12),
                      runSpacing: scaleHeight(12),
                      children: _suggestions
                          .map(
                            (chip) => _SuggestionChip(
                              text: chip,
                              designWidth: _designWidth,
                              designHeight: _designHeight,
                              accentColor: _accentColor,
                              primaryTextColor: _primaryTextColor,
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
      backgroundColor: _backgroundColor,
      body: GestureDetector(
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
                          color: _primaryTextColor,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SvgPicture.asset(
                        'assets/icons/icon_mes.svg',
                        width: scaleWidth(24),
                        height: scaleHeight(24),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scaleHeight(24)),
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFF9E9E9E),
              ),
              SizedBox(height: scaleHeight(24)),
              Expanded(child: conversationArea),
              SizedBox(height: scaleHeight(24)),
              if (_hasConversation && _isTyping) ...[
                Center(
                  child: GestureDetector(
                    onTap: _stopGeneration,
                    child: Container(
                      width: scaleWidth(253),
                      height: scaleHeight(44),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE4E4E4)),
                        borderRadius: BorderRadius.circular(scaleHeight(12)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: scaleWidth(16)),
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
                              'Остановить генерацию...',
                              style: AppTextStyle.bodyTextMedium(
                                scaleHeight(14),
                                color: Colors.black,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(scaleHeight(12)),
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
                                  color: _primaryTextColor,
                                ),
                                cursorColor: _accentColor,
                                decoration: InputDecoration(
                                  hintText: 'Введите вопрос...',
                                  hintStyle: AppTextStyle.bodyTextMedium(
                                    scaleHeight(16),
                                    color: const Color(0xFF9E9E9E),
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
                          borderRadius: BorderRadius.circular(scaleHeight(50)),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/icon_teleg.png',
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
  });

  final String text;
  final double designWidth;
  final double designHeight;
  final Color accentColor;
  final Color primaryTextColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(10),
        vertical: scaleHeight(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scaleHeight(20)),
        border: Border.all(color: accentColor, width: 1),
      ),
      child: Text(
        text,
        style: AppTextStyle.bodyTextMedium(
          scaleHeight(14),
          color: primaryTextColor,
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
  });

  final _ChatMessage message;
  final double designWidth;
  final double designHeight;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / designWidth;
    final double heightFactor = size.height / designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final Color bubbleColor = message.isUser ? accentColor : Colors.white;
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
      color: message.isUser ? Colors.white : const Color(0xFF212121),
      height: message.isUser ? 1 : 21 / 16,
    );

    final Widget bubble = Container(
      constraints: BoxConstraints(
        maxWidth: scaleWidth(message.isUser ? 255 : 308),
      ),
      padding: EdgeInsets.all(scaleHeight(15)),
      decoration: BoxDecoration(color: bubbleColor, borderRadius: borderRadius),
      child: Text(message.text, style: textStyle),
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
            onTap: () => Clipboard.setData(ClipboardData(text: message.text)),
            child: SvgPicture.asset(
              'assets/icons/icon_copy.svg',
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

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
