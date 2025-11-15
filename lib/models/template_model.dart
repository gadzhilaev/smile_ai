import 'package:flutter/material.dart';

class TemplateModel {
  const TemplateModel({
    required this.id,
    required this.category,
    required this.categoryColor,
    required this.title,
    required this.description,
  });

  final int id;
  final String category;
  final Color categoryColor;
  final String title;
  final String description;
}

