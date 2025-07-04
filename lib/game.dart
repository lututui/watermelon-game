import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:watermelon_game/bucket.dart';
import 'package:watermelon_game/fruit.dart';
import 'package:watermelon_game/player.dart';

class WatermelonGame extends Forge2DGame with ContactCallbacks {
  final Player player = Player(startingPosition: Vector2(0, -25));
  final Bucket bucket = Bucket();
  final Timer mergeCooldown = Timer(0.5, autoStart: false);


  @override
  void update(double dt) {
    super.update(dt);

    mergeCooldown.update(dt);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    for (var f in FruitType.values) {
      await Flame.images.load("${f.name}.png");
    }

    camera.viewport.add(FpsTextComponent());
    world.add(bucket);
    world.add(player);
  }
}
