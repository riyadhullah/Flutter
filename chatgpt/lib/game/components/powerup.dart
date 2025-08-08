import 'package:chatgpt/game/components/paddle.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../brick_mania_game.dart';

enum PowerUpType { tripleBall, addScore, removeScore, extraLife }

class PowerUp extends SpriteComponent
    with CollisionCallbacks, HasGameRef<BrickManiaGame> {
  final PowerUpType type;
  Vector2 velocity = Vector2(0, 100); // falling speed

  PowerUp({required this.type, required Vector2 position})
      : super(
    position: position,
    size: Vector2(24, 24),
  );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());

    // You can assign different colors or icons for different types
    switch (type) {
      case PowerUpType.tripleBall:
        paint = Paint()..color = Colors.green;
        break;
      case PowerUpType.addScore:
        paint = Paint()..color = Colors.blue;
        break;
      case PowerUpType.removeScore:
        paint = Paint()..color = Colors.orange;
        break;
      case PowerUpType.extraLife:
        paint = Paint()..color = Colors.red;
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Paddle) {
      // Apply effect
      switch (type) {
        case PowerUpType.tripleBall:
        // Implement triple ball logic
          break;
        case PowerUpType.addScore:
          gameRef.increaseScore(10);
          break;
        case PowerUpType.removeScore:
          gameRef.increaseScore(-5);
          break;
        case PowerUpType.extraLife:
          gameRef.lives += 1;
          break;
      }
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
