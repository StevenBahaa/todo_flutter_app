import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:todo_list/core/theme/theme_x.dart';
import 'package:todo_list/core/utils/responsive.dart';
import 'package:todo_list/l10n/app_localizations.dart';

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: Text(t.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, s) {
          return ListView(
            padding: EdgeInsets.all(r.sp(16)),
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: r.sp(42),
                          backgroundColor: context.surface,
                          backgroundImage: s.userPhotoPath != null
                              ? FileImage(File(s.userPhotoPath!))
                              : null,
                          child: s.userPhotoPath == null
                              ? Icon(
                                  Icons.person,
                                  size: r.sp(36),
                                  color: context.textMuted,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => _profileSheet(context, s),
                            child: Container(
                              padding: EdgeInsets.all(r.sp(6)),
                              decoration: BoxDecoration(
                                color: context.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.border),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: r.sp(16),
                                color: context.scheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: r.sp(12)),

                    GestureDetector(
                      onTap: () => _editName(context, s.userName),
                      child: Text(
                        s.userName,
                        style: TextStyle(
                          fontSize: r.fs(22),
                          fontWeight: FontWeight.w800,
                          color: context.text,
                        ),
                      ),
                    ),

                    SizedBox(height: r.sp(6)),

                    TextButton(
                      onPressed: () => _profileSheet(context, s),
                      child: Text(t.manageProfile),
                    ),
                  ],
                ),
              ),

              SizedBox(height: r.sp(28)),

              _card(
                context,
                padding: r.sp(14),
                children: [
                  Row(
                    children: [
                      Icon(Icons.dark_mode, color: context.primary),
                      SizedBox(width: r.sp(12)),
                      Expanded(
                        child: Text(
                          t.theme,
                          style: TextStyle(color: context.text),
                        ),
                      ),
                      _themeSelector(context, s.themeMode),
                    ],
                  ),

                  SizedBox(height: r.sp(10)),
                  Divider(color: context.border),
                  SizedBox(height: r.sp(6)),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.language, color: context.primary),
                    title: Text(
                      t.language,
                      style: TextStyle(color: context.text),
                    ),
                    trailing: Text(
                      s.langCode == 'ar' ? t.arabic : t.english,
                      style: TextStyle(
                        color: context.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _languageSheet(context),
                  ),
                ],
              ),

              SizedBox(height: r.sp(18)),

              _card(
                context,
                padding: r.sp(14),
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: context.primary),
                      SizedBox(width: r.sp(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.app_version_label,
                              style: TextStyle(
                                color: context.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: r.sp(4)),
                            Text(
                              t.app_version_value,
                              style: TextStyle(
                                color: context.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required double padding,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _themeSelector(BuildContext context, ThemeMode mode) {
    final t = AppLocalizations.of(context)!;

    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: ThemeMode.light, label: Text(t.light)),
        ButtonSegment(value: ThemeMode.dark, label: Text(t.dark)),
      ],
      selected: {mode},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return context.primary.withAlpha((0.18 * 255).toInt());
          }
          return context.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return context.primary;
          return context.textMuted;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: context.border)),
      ),
      onSelectionChanged: (v) {
        context.read<SettingsCubit>().setThemeMode(v.first);
      },
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    context.read<SettingsCubit>().setPhotoPath(x.path);
  }

  void _editName(BuildContext context, String current) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        title: Text(t.editName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: t.yourName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsCubit>().setName(controller.text);
              Navigator.pop(context);
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _languageSheet(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(t.english, style: TextStyle(color: context.text)),
                onTap: () {
                  context.read<SettingsCubit>().setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(t.arabic, style: TextStyle(color: context.text)),
                onTap: () {
                  context.read<SettingsCubit>().setLanguage('ar');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  void _profileSheet(BuildContext context, SettingsState s) {
    final t = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: context.primary),
                  title: Text(
                    t.editName,
                    style: TextStyle(color: context.text),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editName(context, s.userName);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo, color: context.primary),
                  title: Text(
                    t.changePhoto,
                    style: TextStyle(color: context.text),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(context);
                  },
                ),
                if (s.userPhotoPath != null)
                  ListTile(
                    leading: Icon(Icons.delete, color: context.danger),
                    title: Text(
                      t.removePhoto,
                      style: TextStyle(color: context.text),
                    ),
                    onTap: () {
                      context.read<SettingsCubit>().setPhotoPath(null);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
