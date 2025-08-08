import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Paddle extends RectangleComponent with HasGameRef {
  Paddle()
      : super(
    size: Vector2(100, 20),
    paint: Paint()..color = Colors.orange,
  );

  @override
  Future<void> onLoad() async {
    position = Vector2(gameRef.size.x / 2 - size.x / 2, gameRef.size.y - 40);
  }

  @override
  void update(double dt) {
    // Left/right movement can be handled via gesture/keyboard
    super.update(dt);
  }
}
