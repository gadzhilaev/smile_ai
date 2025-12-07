import 'package:flutter/material.dart';
import '../../settings/style.dart';
import '../../settings/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/template_model.dart';
import '../../services/template_service.dart';
import '../../widgets/custom_refresh_indicator.dart';
import '../../utils/template_localization_helper.dart';

class PersonalTemplatesScreen extends StatefulWidget {
  const PersonalTemplatesScreen({
    super.key,
    this.onApplyTemplate,
    this.onEditTemplate,
  });

  final void Function(String, String)? onApplyTemplate;
  final void Function(String, ValueChanged<String>)? onEditTemplate;

  @override
  State<PersonalTemplatesScreen> createState() => _PersonalTemplatesScreenState();
}

class _PersonalTemplatesScreenState extends State<PersonalTemplatesScreen> {
  static const double _designWidth = 428;
  static const double _designHeight = 926;

  List<TemplateModel> _templates = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = await TemplateService.getPersonalTemplates();
    
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTemplates() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _templates = [];
      });
      _scrollController.jumpTo(0);
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    final templates = await TemplateService.getPersonalTemplates();
    
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  void _showAddTemplateDialog() {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true, // Можно закрыть при нажатии вне диалога
      barrierColor: Colors.black.withValues(alpha: 0.5), // Затемненный фон
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
          child: Container(
            width: scaleWidth(380),
            height: scaleHeight(260),
            padding: EdgeInsets.symmetric(
              horizontal: scaleWidth(15),
              vertical: scaleHeight(18),
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок и крестик в одной строке
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Добавить новый шаблон',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: scaleHeight(20),
                          height: 1.0,
                          color: const Color(0xFF5B5B5B),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(scaleHeight(12)),
                      child: Container(
                        width: scaleWidth(24),
                        height: scaleHeight(24),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close,
                          size: scaleHeight(24),
                          color: const Color(0xFF5B5B5B),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleHeight(20)),
                // Текстовое поле - занимает все доступное пространство
                Expanded(
                  child: Container(
                    width: scaleWidth(352),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(scaleHeight(14)),
                      border: Border.all(
                        color: const Color(0x8CA3A3A3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: scaleHeight(14),
                        height: 22 / 14,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Введите текст шаблона',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontSize: scaleHeight(14),
                          height: 22 / 14,
                          letterSpacing: 0,
                          color: const Color(0xFFA3A3A3),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(scaleHeight(12)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: scaleHeight(20)),
                // Кнопка
                Builder(
                  builder: (dialogContext) {
                    return InkWell(
                  onTap: () async {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      await TemplateService.createPersonalTemplate(text);
                          if (!mounted) return;
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        await _refreshTemplates();
                    }
                  },
                  borderRadius: BorderRadius.circular(scaleHeight(16)),
                  child: Container(
                    width: scaleWidth(352),
                    height: scaleHeight(41),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(scaleHeight(16)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Добавить',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        fontSize: scaleHeight(14),
                        color: Colors.white,
                      ),
                    ),
                  ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double widthFactor = size.width / _designWidth;
    final double heightFactor = size.height / _designHeight;

    double scaleWidth(double value) => value * widthFactor;
    double scaleHeight(double value) => value * heightFactor;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.white : theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ваши шаблоны',
          style: AppTextStyle.screenTitleMedium(
            scaleHeight(20),
            color: isDark ? AppColors.white : theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomRefreshIndicator(
              onRefresh: _refreshTemplates,
              designWidth: _designWidth,
              designHeight: _designHeight,
              child: _templates.isEmpty
                  ? SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: scaleHeight(33)),
                            // Текст
                            Text(
                              'У вас пока нет шаблонов в этом разделе. Хотите создать?',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                                fontSize: scaleHeight(20),
                                height: 1.0,
                                color: const Color(0xFF5B5B5B),
                              ),
                            ),
                            SizedBox(height: scaleHeight(33)),
                            // Контейнер для добавления шаблона
                            InkWell(
                              onTap: _showAddTemplateDialog,
                              borderRadius: BorderRadius.circular(scaleHeight(13)),
                              child: Container(
                                width: double.infinity,
                                height: scaleHeight(90),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                                ),
                                child: Stack(
                                  children: [
                                    // Пунктирная обводка
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        return CustomPaint(
                                          size: Size(constraints.maxWidth, scaleHeight(90)),
                                          painter: _DashedBorderPainter(
                                            color: const Color(0xFF9E9E9E),
                                            strokeWidth: 1,
                                            borderRadius: scaleHeight(13),
                                          ),
                                        );
                                      },
                                    ),
                                    // Контент по центру
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Иконка плюсик
                                          Icon(
                                            Icons.add,
                                            size: scaleHeight(24),
                                            color: const Color(0xFF9E9E9E),
                                          ),
                                          SizedBox(height: scaleHeight(4)),
                                          // Текст
                                          Text(
                                            'Добавить шаблон',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                              fontSize: scaleHeight(8),
                                              color: const Color(0xFF9E9E9E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: scaleWidth(24)),
                      itemCount: _templates.length + 1, // +1 для контейнера "Добавить шаблон"
                      itemBuilder: (context, index) {
                        if (index == _templates.length) {
                          // Последний элемент - контейнер "Добавить шаблон"
                          return Padding(
                            padding: EdgeInsets.only(
                              top: scaleHeight(20),
                              bottom: scaleHeight(20),
                            ),
                            child: InkWell(
                              onTap: _showAddTemplateDialog,
                              borderRadius: BorderRadius.circular(scaleHeight(13)),
                              child: Container(
                                width: double.infinity,
                                height: scaleHeight(90),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(scaleHeight(13)),
                                ),
                                child: Stack(
                                  children: [
                                    // Пунктирная обводка
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        return CustomPaint(
                                          size: Size(constraints.maxWidth, scaleHeight(90)),
                                          painter: _DashedBorderPainter(
                                            color: const Color(0xFF9E9E9E),
                                            strokeWidth: 1,
                                            borderRadius: scaleHeight(13),
                                          ),
                                        );
                                      },
                                    ),
                                    // Контент по центру
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Иконка плюсик
                                          Icon(
                                            Icons.add,
                                            size: scaleHeight(24),
                                            color: const Color(0xFF9E9E9E),
                                          ),
                                          SizedBox(height: scaleHeight(4)),
                                          // Текст
                                          Text(
                                            'Добавить шаблон',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w600,
                                              fontSize: scaleHeight(8),
                                              color: const Color(0xFF9E9E9E),
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
                        final template = _templates[index];
                        return _buildTemplateCard(template, scaleWidth, scaleHeight, isDark, theme);
                      },
                    ),
            ),
    );
  }

  Widget _buildTemplateCard(
    TemplateModel template,
    double Function(double) scaleWidth,
    double Function(double) scaleHeight,
    bool isDark,
    ThemeData theme,
  ) {
    final l = AppLocalizations.of(context)!;
    
    return Container(
      margin: EdgeInsets.only(bottom: scaleHeight(20)),
      padding: EdgeInsets.symmetric(
        horizontal: scaleWidth(14),
        vertical: scaleHeight(11),
      ),
      decoration: BoxDecoration(
        color: AppColors.white, // В темной теме используем тот же белый цвет, что и в светлой
        borderRadius: BorderRadius.circular(scaleHeight(12)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.overlayShadow,
            offset: Offset(0, 14),
            blurRadius: 64,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.overlayShadow,
            offset: Offset(0, 8),
            blurRadius: 22,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              getLocalizedTemplateTitle(l, template),
              textAlign: TextAlign.left,
              style: AppTextStyle.templateTitle(
                scaleHeight(16),
              ).copyWith(
                height: 18 / 16,
                color: AppColors.textPrimary, // В темной теме используем тот же цвет текста, что и в светлой
              ),
            ),
          ),
          SizedBox(height: scaleHeight(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  if (widget.onApplyTemplate != null) {
                    widget.onApplyTemplate!(getLocalizedTemplateTitle(l, template), template.category);
                  }
                },
                borderRadius: BorderRadius.circular(scaleHeight(16)),
                child: Container(
                  width: scaleWidth(187),
                  height: scaleHeight(41),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFCBE5F8),
                              Color(0xFFD6D7F8),
                            ],
                            stops: [0.0, 0.7816],
                          ),
                    borderRadius: BorderRadius.circular(scaleHeight(16)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l.templateApply,
                    style: AppTextStyle.templateButton(
                      scaleHeight(14),
                    ).copyWith(
                      color: AppColors.textPrimary, // В темной теме используем тот же цвет текста, что и в светлой
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  if (widget.onEditTemplate != null) {
                    widget.onEditTemplate!(getLocalizedTemplateTitle(l, template), (editedText) async {
                      // Обновляем шаблон с новым текстом
                      await TemplateService.updatePersonalTemplate(template.id, editedText);
                      await _refreshTemplates();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(scaleHeight(16)),
                child: Container(
                  width: scaleWidth(152),
                  height: scaleHeight(41),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0x801E293B),
                    borderRadius: BorderRadius.circular(scaleHeight(16)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l.templateEdit,
                    style: AppTextStyle.templateButtonWhite(
                      scaleHeight(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    // Рисуем пунктирную линию (dashes: 16, 16)
    const dashWidth = 16.0;
    const dashSpace = 16.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double start = 0.0;
      while (start < pathMetric.length) {
        final end = (start + dashWidth).clamp(0.0, pathMetric.length);
        final extractPath = pathMetric.extractPath(start, end);
        canvas.drawPath(extractPath, paint);
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

