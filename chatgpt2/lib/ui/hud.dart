import 'package:flame/components.dart';
import '../game/brick_mania_game.dart';

class Hud extends PositionComponent with HasGameRef<BrickManiaGame> {
  late final TextComponent scoreText;
  late final TextComponent lifeText;

  @override
  Future<void> onLoad() async {
    position = Vector2(8, 8);
    scoreText = TextComponent(text: '★ 0', anchor: Anchor.topLeft);
    lifeText  = TextComponent(text: '♥ 3', anchor: Anchor.topLeft)
      ..position = Vector2(100, 0);
    addAll([scoreText, lifeText]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText.text = '★ ${gameRef.score}';
    lifeText.text  = '♥ ${gameRef.lives}';
  }
}
