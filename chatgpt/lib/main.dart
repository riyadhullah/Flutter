import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/brick_mania_game.dart';
import 'game/widgets/hud_overlay.dart';


void main() {
  runApp(
    GameWidget<BrickManiaGame>(
      game: BrickManiaGame(),
      overlayBuilderMap: {
        'HUD': (context, game) => HUDOverlay(gameRef: game),
      },
      initialActiveOverlays: const ['HUD'],
    ),
  );
}
