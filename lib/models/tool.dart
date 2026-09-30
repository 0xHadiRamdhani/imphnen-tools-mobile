import 'package:flutter/material.dart';

class ToolCategory {
  const ToolCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String id;
  final String title;
  final IconData icon;
  final String description;
}

class ToolDefinition {
  const ToolDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    this.local = true,
    this.popular = false,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final bool local;
  final bool popular;
}
