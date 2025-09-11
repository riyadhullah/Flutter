import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import '../game/brick_mania_game.dart';
import 'package:flutter/material.dart';


class Paddle extends RectangleComponent
    with DragCallbacks, CollisionCallbacks, HasGameRef<BrickManiaGame> {
  Paddle() : super(size: Vector2(80, 12), anchor: Anchor.center, paint: Paint()..color = const Color(0xFFFF8A3D));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.x += event.localDelta.x;
    // clamp within screen
    final minX = size.x / 2;
    final maxX = gameRef.size.x - size.x / 2;
    position.x = position.x.clamp(minX, maxX);
  }
}
