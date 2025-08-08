import 'package:flame_audio/flame_audio.dart';

class AudioHelper {
  static void playBrickBreak() => FlameAudio.play('brick.wav');
  static void playLoseLife() => FlameAudio.play('lose.wav');
}
