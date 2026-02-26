import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';

class PrettyField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final int maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const PrettyField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: TextStyle(
        color: context.text,
        fontWeight: FontWeight.w700,
        fontSize: r.fs(14),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: context.textMuted),
        filled: true,
        fillColor: context.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: r.sp(14),
          vertical: r.sp(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.sp(14)),
          borderSide: BorderSide(color: context.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r.sp(14)),
          borderSide: BorderSide(
            color: context.primary.withAlpha((0.70 * 255).toInt()),
            width: 1.3,
          ),
        ),
      ),
    );
  }
}