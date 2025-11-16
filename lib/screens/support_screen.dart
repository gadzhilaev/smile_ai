import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../settings/style.dart';
import '../settings/colors.dart';
import '../l10n/app_localizations.dart';
import '../services/profile_service.dart';

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

  @override
  void initState() {
    super.initState();
    _addInitialSupportMessage();
  }

  void _addInitialSupportMessage() {
    final fullName = ProfileService.instance.fullName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      final greeting =
          '${l.supportGreetingPrefix}, ${fullName.isNotEmpty ? fullName : l.supportDefaultName}!';
      setState(() {
        _messages.add(
          _SupportMessage(
            fromSupport: true,
            text: greeting,
            isGreeting: true,
          ),
        );
      });
      _scrollToBottom();
    });
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

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _SupportMessage(
          fromSupport: false,
          text: text,
        ),
      );
      _inputController.clear();
    });
    _scrollToBottom();
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
                SizedBox(height: scaleHeight(30)),
                // Чат
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: scaleWidth(24),
                      right: scaleWidth(24),
                      bottom: scaleHeight(35),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isLast = index == _messages.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: isLast ? 0 : scaleHeight(20),
                          ),
                          child: Align(
                            alignment: message.fromSupport
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: _SupportBubble(
                              message: message,
                              designWidth: SupportScreen._designWidth,
                              designHeight: SupportScreen._designHeight,
                            ),
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
                      SvgPicture.asset(
                        'assets/icons/icon_clip.svg',
                        width: scaleWidth(24),
                        height: scaleWidth(24),
                        colorFilter: ColorFilter.mode(
                          isDark ? AppColors.white : AppColors.black,
                          BlendMode.srcIn,
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
                        onTap: _sendMessage,
                        child: Image.asset(
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
  });

  final bool fromSupport;
  final String text;
  final bool isGreeting;
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
        vertical: scaleHeight(10),
      ),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nameText,
            style: AppTextStyle.bodyText(
              scaleHeight(14),
              color: isDark
                  ? AppColors.darkSecondaryText
                  : const Color(0xFF656565),
            ),
          ),
          Text(
            messageText,
            style: AppTextStyle.screenTitle(
                    scaleHeight(16),
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
          ),
        ],
      ),
    );
  }
}


