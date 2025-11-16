import 'package:flutter/material.dart';

class TemplateModel {
  const TemplateModel({
    required this.id,
    required this.category,
    required this.categoryColor,
    required this.title,
  });

  final int id;
  final String category;
  final Color categoryColor;
  final String title;
}

