import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/app_colors.dart';

class AnimatedCheck extends StatelessWidget {
  final bool checked;
  final Color color;
  final VoidCallback onTap;

  const AnimatedCheck({
    super.key,
    required this.checked,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: checked ? color.withAlpha((0.20 * 255).toInt()) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: checked ? color : AppColors.border,
            width: 2,
          ),
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: checked ? 1.0 : 0.0,
          child: Icon(Icons.check, size: 16, color: color),
        ),
      ),
    );
  }
}
