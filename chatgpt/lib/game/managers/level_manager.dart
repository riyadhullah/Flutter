import '../brick_mania_game.dart';
import 'package:flame/components.dart';
import '../components/brick.dart';

class LevelManager {
  final BrickManiaGame game;

  LevelManager(this.game);

  Future<void> loadLevel(int level) async {
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 8; col++) {
        final brick = Brick(position: Vector2(30 + col * 45, 50 + row * 25));
        game.add(brick);
      }
    }
  }
}
