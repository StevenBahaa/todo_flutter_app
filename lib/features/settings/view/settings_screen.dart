import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import 'package:todo_list/core/theme/theme_x.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: const Text("Settings")),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, s) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ================= PROFILE HEADER =================
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: context.surface,
                          backgroundImage: s.userPhotoPath != null
                              ? FileImage(File(s.userPhotoPath!))
                              : null,
                          child: s.userPhotoPath == null
                              ? const Icon(Icons.person, size: 36)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: context.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () => _editName(context, s.userName),
                      child: Text(
                        s.userName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: context.text,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextButton(
                      onPressed: () => _editName(context, s.userName),
                      child: const Text("Manage Profile"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ================= PREFERENCES CARD =================
              _card(
                context,
                children: [
                  // THEME
                  Row(
                    children: [
                      Icon(Icons.dark_mode, color: context.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Theme",
                          style: TextStyle(color: context.text),
                        ),
                      ),
                      _themeSelector(context, s.themeMode),
                    ],
                  ),

                  const Divider(),

                  // LANGUAGE
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.language, color: context.primary),
                    title: Text(
                      "Language",
                      style: TextStyle(color: context.text),
                    ),
                    trailing: Text(
                      s.langCode == 'ar' ? "العربية" : "English",
                      style: TextStyle(color: context.textMuted),
                    ),
                    onTap: () => _languageSheet(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border),
      ),
      child: Column(children: children),
    );
  }

  // ================= THEME SELECTOR =================
  Widget _themeSelector(BuildContext context, ThemeMode mode) {
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(context.surface),
      ),
      segments: const [
        ButtonSegment(value: ThemeMode.light, label: Text("Light")),
        ButtonSegment(value: ThemeMode.dark, label: Text("Dark")),
      ],
      selected: {mode},
      onSelectionChanged: (v) {
        context.read<SettingsCubit>().setThemeMode(v.first);
      },
    );
  }

  // ================= IMAGE PICK =================
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    context.read<SettingsCubit>().setPhotoPath(x.path);
  }

  // ================= NAME EDIT =================
  void _editName(BuildContext context, String current) {
    final controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        title: const Text("Edit Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              context.read<SettingsCubit>().setName(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= LANGUAGE SHEET =================
  void _languageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          color: context.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  context.read<SettingsCubit>().setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("العربية"),
                onTap: () {
                  context.read<SettingsCubit>().setLanguage('ar');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
