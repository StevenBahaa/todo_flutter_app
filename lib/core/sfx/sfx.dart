import 'package:audioplayers/audioplayers.dart';

class Sfx {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> check() async {
    await _player.stop();
    // await _player.play(AssetSource('sfx/Task_Finished_Tone.mp3'));
    await _player.play(AssetSource('sfx/Job_Well_Done_Ding.mp3'));
    // await _player.play(AssetSource('sfx/task_done.mp3'));
  }
}