import 'dart:convert';
import 'package:flame/components.dart';
import '../components/brick.dart';
import 'brick_mania_game.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';


class LevelLoader {
  final BrickManiaGame game;
  LevelLoader(this.game);

  // Simple ASCII map:
  // '.' = empty, '1' = hp1 brick, '2' = hp2 brick, 'r','o','y','p' = colored bricks
  Future<void> loadFromAscii(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final lines = const LineSplitter().convert(raw);

    final cols = lines.isEmpty ? 0 : lines[0].length;
    final brickW = 14.0;
    final brickH = 8.0;
    final gap = 2.0;

    final totalWidth = cols * brickW + (cols - 1) * gap;
    final left = (game.size.x - totalWidth) / 2;
    double top = 80;

    for (final row in lines) {
      double x = left;
      for (final ch in row.characters) {
        if (ch != '.') {
          final color = switch (ch) {
            'r' => const Color(0xFFE53935),
            'o' => const Color(0xFFFF8A3D),
            'y' => const Color(0xFFFFD54F),
            'p' => const Color(0xFF9C27B0),
            _ => const Color(0xFFBDBDBD),
          };
          final hp = int.tryParse(ch) ?? 1;
          game.add(Brick(
            position: Vector2(x + brickW / 2, top + brickH / 2),
            size: Vector2(brickW, brickH),
            hp: hp,
            scoreValue: 10 * hp,
            color: color,
          ));
        }
        x += brickW + gap;
      }
      top += brickH + gap;
    }
  }
}
