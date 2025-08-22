import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:watermelon_game/bucket.dart';
import 'package:watermelon_game/fruit.dart';
import 'package:watermelon_game/overlay/game_over.dart';
import 'package:watermelon_game/overlay/pause.dart';
import 'package:watermelon_game/player.dart';
import 'package:window_manager/window_manager.dart';

class WatermelonGame extends Forge2DGame with WindowListener {
  final Player player = Player();
  final Bucket bucket = Bucket();
  final Set<Fruit> fruit = {};

  final Timer mergeCooldown = Timer(0.1, autoStart: false);

  ValueNotifier<int> score = ValueNotifier(0);
  bool gameOver = false;

  WatermelonGame() : super(zoom: WatermelonGameConstants.zoom);

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver) {
      if (kDebugMode) {
        print("Game over. Score: ${score.value}");
      }

      pauseEngine();
      overlays.add(GameOverOverlayConstants.overlayId);
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

    windowManager.addListener(this);
  }


  @override
  void onDispose() {
    windowManager.removeListener(this);

    super.onDispose();
  }

  void resetGame() {
    score.value = 0;
    gameOver = false;

    for (var it in [...fruit]) {
      fruit.remove(it);
      it.removeFromParent();
    }

    assert(fruit.isEmpty);

    resumeEngine();
  }

  @override
  void onWindowRestore() {
    overlays.add(PauseOverlayConstants.overlayId);
    pauseEngine();
  }
}

class WatermelonGameConstants {
  static const double zoom = 10.0;

  WatermelonGameConstants._();
}
