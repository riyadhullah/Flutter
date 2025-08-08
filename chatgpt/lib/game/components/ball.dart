import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart'; // For HasGameReference
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../brick_mania_game.dart';

class Ball extends CircleComponent with CollisionCallbacks, HasGameReference<BrickManiaGame> {
  Vector2 velocity = Vector2(150, -150);

  Ball()
      : super(
    radius: 7,
    paint: Paint()..color = const Color(0xFFFFFFFF), // white ball
  );

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 2, game.size.y - 60);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Wall bounce
    if (position.x <= 0 || position.x + radius * 2 >= game.size.x) {
      velocity.x *= -1;
    }

    if (position.y <= 0) {
      velocity.y *= -1;
    }

    // Bottom out (lose life)
    if (position.y >= game.size.y) {
      game.loseLife();
    }
  }

  void reset() {
    position = Vector2(game.size.x / 2, game.size.y - 60);
    velocity = Vector2(150, -150);
  }
}
