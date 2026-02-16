import 'package:audioplayers/audioplayers.dart';

class Sfx {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> check() async {
    await _player.stop();
    await _player.play(AssetSource('sfx/task_done.mp3'));
  }
}
