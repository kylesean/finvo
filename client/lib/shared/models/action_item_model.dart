// shared/models/action_item_model.dart (or similar location)
import 'package:flutter/material.dart';

class ActionItem {
  final String title;
  final String?
  subtitle; // Secondary explanatory line (e.g. what an option does)
  final IconData icon;
  final VoidCallback onTap;
  final Color? color; // To override theme color if needed
  final bool isDestructive; // New field
  final Object? result; // Optional selection value returned by the sheet

  ActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.color,
    this.isDestructive = false, // Default to false
    this.result,
  });
}
