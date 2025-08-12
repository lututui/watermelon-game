import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:watermelon_game/bucket.dart';
import 'package:watermelon_game/fruit.dart';
import 'package:watermelon_game/player.dart';

class WatermelonGame extends Forge2DGame {
  final Player player = Player();
  final Bucket bucket = Bucket();

  final Timer mergeCooldown = Timer(0.1, autoStart: false);

  late final Function(int) onScoreChangeCallback;

  ValueNotifier<int> score = ValueNotifier(0);
  bool gameOver = false;

  WatermelonGame() : super(zoom: WatermelonGameConstants.zoom);

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver) {
      if (kDebugMode) {
        print("Game over. Score: $score");
      }

      pauseEngine();
      overlays.add('GameOver');
    }

    mergeCooldown.update(dt);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    for (var f in FruitType.values) {
      await Flame.images.load("fruit/${f.name}.png");
    }

    final backgroundImage = await Flame.images.load("background.png");

    if (kDebugMode) {
      camera.viewport.add(FpsTextComponent());
    }

    world.add(
      SpriteComponent(
        sprite: Sprite(backgroundImage),
        anchor: Anchor.center,
        size: size / WatermelonGameConstants.zoom,
      ),
    );
    world.add(bucket);
    world.add(player);
  }
}

class WatermelonGameConstants {
  static const double zoom = 10.0;

  WatermelonGameConstants._();
}
