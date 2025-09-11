import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import '../components/ball.dart';
import '../components/paddle.dart';
import 'level_loader.dart';
import '../ui/hud.dart';

class BrickManiaGame extends FlameGame
    with HasCollisionDetection, HasDraggables, HasTappables {

  late AudioPool sfxHit;
  late AudioPool sfxBrick;

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(resolution: worldSize);

    // Load audio files into memory
    await FlameAudio.audioCache.loadAll(['hit.wav', 'brick.wav']);

    // Create reusable sound effect pools
    sfxHit   = await FlameAudio.createPool('hit.wav', maxPlayers: 3);
    sfxBrick = await FlameAudio.createPool('brick.wav', maxPlayers: 3);

    // The rest of your onLoad() code...
  }
}
