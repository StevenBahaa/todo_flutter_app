import 'package:hive/hive.dart';
import 'hive_boxes.dart';
import 'prefs_keys.dart';

class UserProfilePrefs {
  Box get _prefs => Hive.box(HiveBoxs.prefs);

  String? getName() => _prefs.get(PrefsKeys.userName) as String?;
  String? getPhotoPath() => _prefs.get(PrefsKeys.userPhotoPath) as String?;

  Future<void> saveProfile({required String name, String? photoPath}) async {
    await _prefs.put(PrefsKeys.userName, name);
    await _prefs.put(PrefsKeys.userPhotoPath, photoPath);
  }

  bool getOnboardingDone() =>
      (_prefs.get(PrefsKeys.onboardingDone) as bool?) ?? false;

  Future<void> setOnboardingDone(bool v) async {
    await _prefs.put(PrefsKeys.onboardingDone, v);
  }
}
