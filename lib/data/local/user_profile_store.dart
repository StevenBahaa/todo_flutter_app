import 'package:hive/hive.dart';
import '../models/user_profile.dart';

class UserProfileStore {
  static const boxName = 'user_profile_box';
  static const key = 'profile';

  Future<Box<UserProfile>> _box() async => Hive.openBox<UserProfile>(boxName);

  Future<UserProfile?> getProfile() async {
    final box = await _box();
    return box.get(key);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = await _box();
    await box.put(key, profile);
  }
}



