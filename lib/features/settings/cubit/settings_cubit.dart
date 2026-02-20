import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data/local/hive_boxes.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState(
    userName: 'User',
    userPhotoPath: null,
    themeMode: ThemeMode.dark,
    langCode: 'en',
  ));

  Box get _prefs => Hive.box(HiveBoxs.prefs);

  Future<void> load() async {
    final name = (_prefs.get('user_name') as String?)?.trim();
    final photo = (_prefs.get('user_photo_path') as String?)?.trim();
    final theme = (_prefs.get('theme_mode') as String?) ?? 'dark';
    final lang = (_prefs.get('lang_code') as String?) ?? 'en';

    emit(state.copyWith(
      userName: (name != null && name.isNotEmpty) ? name : 'User',
      userPhotoPath: (photo != null && photo.isNotEmpty) ? photo : null,
      themeMode: theme == 'light' ? ThemeMode.light : ThemeMode.dark,
      langCode: (lang == 'ar') ? 'ar' : 'en',
    ));
  }

  Future<void> setName(String name) async {
    final v = name.trim();
    await _prefs.put('user_name', v);
    emit(state.copyWith(userName: v.isEmpty ? 'User' : v));
  }

  Future<void> setPhotoPath(String? path) async {
    if (path == null || path.trim().isEmpty) {
      await _prefs.delete('user_photo_path');
      emit(state.copyWith(userPhotoPath: null));
      return;
    }
    await _prefs.put('user_photo_path', path.trim());
    emit(state.copyWith(userPhotoPath: path.trim()));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.put('theme_mode', mode == ThemeMode.light ? 'light' : 'dark');
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLanguage(String code) async {
    final v = (code == 'ar') ? 'ar' : 'en';
    await _prefs.put('lang_code', v);
    emit(state.copyWith(langCode: v));
  }
}
