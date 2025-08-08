import 'package:flutter/material.dart';
import '../brick_mania_game.dart';

class HUDOverlay extends StatelessWidget {
  final BrickManiaGame gameRef;
  const HUDOverlay({super.key, required this.gameRef});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score: ${gameRef.score}', style: const TextStyle(color: Colors.white, fontSize: 20)),
          Text('Lives: ${gameRef.lives}', style: const TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }
}
