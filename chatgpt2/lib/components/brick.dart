import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/brick_mania_game.dart';
import 'package:flutter/material.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameRef<BrickManiaGame> {
  int hp;
  final int scoreValue;

  Brick({
    required Vector2 position,
    required Vector2 size,
    this.hp = 1,
    this.scoreValue = 10,
    Color color = const Color(0xFFFFD54F),
  }) : super(position: position, size: size, paint: Paint()..color = color, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  void hit() {
    hp -= 1;
    if (hp <= 0) {
      gameRef.addScore(scoreValue);
      gameRef.sfxBrick.start(); // Play brick break sound
      removeFromParent();
    } else {
      gameRef.sfxHit.start(); // Play weaker hit sound
      paint.color = paint.color.withAlpha((paint.color.alpha * 0.7).toInt());
    }
  }

}
