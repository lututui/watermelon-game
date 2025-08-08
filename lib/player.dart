import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:watermelon_game/bucket.dart';
import 'package:watermelon_game/fruit.dart';
import 'package:watermelon_game/game.dart';

class Player extends BodyComponent<WatermelonGame> {
  final Vector2 startingPosition;

  Fruit? nextFruit;

  Player({required this.startingPosition}) : super(renderBody: false);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      gravityOverride: Vector2(0, 0),
      position: startingPosition,
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
      -Bucket.xBound + Bucket.dxBound + 1.1 * fruitRadius,
      Bucket.xBound - 1.01 * fruitRadius,
    );

    game.player.position.x = newPos;
    game.player.nextFruit?.position.x = newPos;
  }
}
