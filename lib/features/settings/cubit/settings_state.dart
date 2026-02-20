import 'package:flutter/material.dart';

class SettingsState {
  final String userName;
  final String? userPhotoPath;
  final ThemeMode themeMode;
  final String langCode;

  const SettingsState({
    required this.userName,
    required this.userPhotoPath,
    required this.themeMode,
    required this.langCode,
  });

  SettingsState copyWith({
    String? userName,
    String? userPhotoPath,
    ThemeMode? themeMode,
    String? langCode,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      userPhotoPath: userPhotoPath ?? this.userPhotoPath,
      themeMode: themeMode ?? this.themeMode,
      langCode: langCode ?? this.langCode,
    );
  }
}
