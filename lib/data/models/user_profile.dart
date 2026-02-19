import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 50)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? photoPath; // local file path

  UserProfile({required this.name, this.photoPath});
}
