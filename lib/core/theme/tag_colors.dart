import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/app_colors.dart';

class TagColors {
  static const Map<String, Color> _map = {
    'urgent': AppColors.danger,
    'work': Color(0xFF4F8CFF),
    'personal': Color(0xFFB26CFF),
    'health': Color(0xFF22C55E),
    'study': Color(0xFF06B6D4),
    'home': Color(0xFFF59E0B),
    'finance': Color(0xFF10B981),
  };
  static Color resolve(String tag) {
    final key = tag.toLowerCase();
    return _map[key] ?? AppColors.primary;
  }
}
