import 'package:flutter/material.dart';
import 'package:todo_list/core/theme/tag_colors.dart';
import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/l10n/app_localizations.dart';
import 'pretty_field.dart';

class TagsSection extends StatelessWidget {
  final TextEditingController controller;
  final List<String> tags;
  final VoidCallback onAdd;
  final void Function(String) onDelete;

  const TagsSection({
    super.key,
    required this.controller,
    required this.tags,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final r = R(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.tagsLabel,
          style: TextStyle(
            color: context.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: r.sp(10)),
        Row(
          children: [
            Expanded(
              child: PrettyField(
                controller: controller,
                hint: t.addTagsHint,
                onSubmitted: (_) => onAdd(),
              ),
            ),
            SizedBox(width: r.sp(8)),
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add, color: context.primary),
            ),
          ],
        ),
        SizedBox(height: r.sp(10)),
        if (tags.isEmpty)
          Text(t.noTags,
              style: TextStyle(color: context.textMuted))
        else
          Wrap(
            spacing: r.sp(8),
            runSpacing: r.sp(8),
            children: tags.map((tag) {
              final c = TagColors.resolve(tag);

              return Chip(
                label: Text("#$tag"),
                labelStyle: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w900,
                ),
                backgroundColor:
                    c.withAlpha((0.16 * 255).toInt()),
                side: BorderSide(
                    color: c.withAlpha((0.45 * 255).toInt())),
                deleteIconColor:
                    c.withAlpha((0.85 * 255).toInt()),
                onDeleted: () => onDelete(tag),
              );
            }).toList(),
          ),
      ],
    );
  }
}