import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/brick_mania_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(game: BrickManiaGame()),
      ),
    ),
  );
}
