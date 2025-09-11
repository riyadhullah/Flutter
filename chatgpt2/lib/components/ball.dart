import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/brick_mania_game.dart';
import 'paddle.dart';
import 'brick.dart';
import 'package:flutter/material.dart';


class Ball extends CircleComponent
    with CollisionCallbacks, HasGameRef<BrickManiaGame> {
  Vector2 velocity = Vector2(160, -220);

  Ball()
      : super(
    radius: 5,
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFFFFFFFF),
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // bounce on walls (top/left/right)
    if (position.x - radius <= 0 || position.x + radius >= gameRef.size.x) {
      velocity.x = -velocity.x;
    }
    if (position.y - radius <= 0) {
      velocity.y = -velocity.y;
    }
    // fell below screen -> lose life
    if (position.y - radius > gameRef.size.y) {
      gameRef.loseLife();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is Paddle) {
      gameRef.sfxHit.start(); // Play paddle hit sound
      // Rest of your bounce logic...
    }

   else if (other is Brick) {
      other.hit();
      // simple reflect: flip Y by default; if hitting side, flip X
      final hitPoint = points.first;
      final dx = (hitPoint.x - other.position.x).abs();
      final dy = (hitPoint.y - other.position.y).abs();
      if (dx > dy) {
        velocity.x = -velocity.x;
      } else {
        velocity.y = -velocity.y;
      }
    }
    super.onCollision(points, other);
  }

  void reset(Vector2 pos) {
    position = pos;
    velocity = Vector2(160, -220);
  }
}
