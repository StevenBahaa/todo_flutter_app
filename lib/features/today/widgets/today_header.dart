import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/data/local/hive_boxes.dart';
import 'package:todo_list/features/settings/view/settings_screen.dart';
import 'package:todo_list/l10n/app_localizations.dart';

class TodayHeader extends StatelessWidget {
  final DateTime now;
  const TodayHeader({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final prefs = Hive.box(HiveBoxs.prefs);

    final locale = Localizations.localeOf(context).languageCode;
    final dateText = DateFormat('EEE, d MMM', locale).format(now);

    return ValueListenableBuilder(
      valueListenable: prefs.listenable(
        keys: const ['user_name', 'user_photo_path'],
      ),
      builder: (context, Box box, _) {
        final rawName = (box.get('user_name') as String?)?.trim();
        final name = (rawName != null && rawName.isNotEmpty) ? rawName : t.user;

        final rawPath = (box.get('user_photo_path') as String?)?.trim();
        final File? photoFile =
            (rawPath != null &&
                rawPath.isNotEmpty &&
                File(rawPath).existsSync())
            ? File(rawPath)
            : null;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(photoFile: photoFile),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.welcomeBack,
                    style: TextStyle(
                      color: context.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: context.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: context.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: Icon(Icons.settings_rounded, color: context.textMuted),
            ),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final File? photoFile;
  const _Avatar({required this.photoFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.border, width: 1),
      ),
      child: ClipOval(
        child: photoFile != null
            ? Image.file(photoFile!, fit: BoxFit.cover)
            : Container(
                color: context.surface,
                child: Icon(Icons.person, color: context.textMuted),
              ),
      ),
    );
  }
}
