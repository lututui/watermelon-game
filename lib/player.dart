import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';

class Player extends BodyComponent<WatermelonGame> {
  static final double xSize = 1;
  static final double ySize = 1;

  final Vector2 startingPosition;

  Player({required this.startingPosition})
    : super(paint: Paint()..color = Colors.red);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      gravityOverride: Vector2(0, 0),
      position: startingPosition,
    );

    final player = world.createBody(bodyDef);

    player.createFixture(FixtureDef(CircleShape(radius: 1.0), isSensor: true));

    return player;
  }
}
