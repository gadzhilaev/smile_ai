import 'package:flutter/material.dart';

class TemplateModel {
  const TemplateModel({
    required this.id,
    required this.category,
    required this.categoryColor,
    required this.title,
    this.isCustom = false,
    this.categoryId,
  });

  final int id;
  final String category;
  final Color categoryColor;
  final String title;
  final bool isCustom;
  final String? categoryId; // ID категории для поиска независимо от языка
}

