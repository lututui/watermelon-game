import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:watermelon_game/bucket.dart';
import 'package:watermelon_game/fruit.dart';
import 'package:watermelon_game/game.dart';

class Player extends BodyComponent<WatermelonGame> {
  Fruit? nextFruit;

  Player() : super(renderBody: false);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      gravityOverride: Vector2.zero(),
      position: PlayerConstants.startingPosition,
    );

    final player = world.createBody(bodyDef);

    nextFruit = FruitType.random(player.position);
    world.add(nextFruit!);

    return player;
  }

  void updatePosition({double? newPos, double? deltaPos}) {
    newPos ??= game.player.position.x + (deltaPos ?? 0);

    final fruitRadius = game.player.nextFruit?.type.radius ?? 0;

    newPos = clampDouble(
      newPos,
      -BucketConstants.lengthX + BucketConstants.widthX + 1.1 * fruitRadius,
      BucketConstants.lengthX - 1.01 * fruitRadius,
    );

    game.player.position.x = newPos;
    game.player.nextFruit?.position.x = newPos;
  }
}

class PlayerConstants {
  static final Vector2 startingPosition = Vector2(0, -20);

  PlayerConstants._();
}