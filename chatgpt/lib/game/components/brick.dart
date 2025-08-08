import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../brick_mania_game.dart';
import 'ball.dart';


class Brick extends RectangleComponent with CollisionCallbacks, HasGameRef<BrickManiaGame> {
  Brick({required Vector2 position})
      : super(
    size: Vector2(40, 20),
    position: position,
    paint: Paint()..color = Colors.redAccent,
  );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Ball) {
      gameRef.increaseScore(10);
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
