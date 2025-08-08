import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'; // 👈 এইটা লাগবে Color class এর জন্য

import 'components/paddle.dart';
import 'components/ball.dart';
import 'managers/level_manager.dart';
import 'managers/collision_manager.dart';

class BrickManiaGame extends FlameGame with HasCollisionDetection {
  late Paddle paddle;
  late Ball ball;
  late LevelManager levelManager;
  late CollisionManager collisionManager;

  int score = 0;
  int lives = 3;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF); // <-- 🟣 New background color

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    levelManager = LevelManager(this);
    collisionManager = CollisionManager(this);

    await levelManager.loadLevel(1);

    paddle = Paddle();
    ball = Ball();

    add(paddle);
    add(ball);
  }

  void resetBall() {
    ball.reset();
  }

  void increaseScore(int amount) {
    score += amount;
  }

  void loseLife() {
    lives--;
    if (lives <= 0) {
      pauseEngine();
      overlays.add('GameOver');
    } else {
      resetBall();
    }
  }
}
