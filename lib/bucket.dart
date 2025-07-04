import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';

class Bucket extends BodyComponent<WatermelonGame> with TapCallbacks {
  static final double xBound = 20;
  static final double yBound = 20;
  static final double dxBound = 0.5;
  static final double dyBound = 0.5;

  final Timer _spawnTimer = Timer(2, autoStart: false);

  Bucket()
    : super(
        paint:
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
      );

  void createFixture(Body body) {
    final topL = Vector2(-xBound, -yBound);
    final botL = Vector2(-xBound, yBound);
    final topR = Vector2(xBound, -yBound);
    final botR = Vector2(xBound, yBound);

    final rightward = Vector2(dxBound, 0);
    final upward = Vector2(0, -dyBound);

    final shapes = [
      [topL, botL, botL + rightward, topL + rightward], // left
      [botL, botR, botR + upward, botL + upward], // bottom
      [botR, botR + rightward, topR + rightward, topR], // right
    ];

    for (var shape in shapes) {
      body.createFixture(FixtureDef(PolygonShape()..set(shape)));
    }

    final sensor = [topL, botL, botR, topR];

    body.createFixture(FixtureDef(PolygonShape()..set(sensor), isSensor: true));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef();

    bodyDef.position = Vector2.zero();
    bodyDef.type = BodyType.static;

    final body = world.createBody(bodyDef);

    createFixture(body);

    return body;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (_spawnTimer.isRunning()) return;

    _spawnTimer.start();

    final eventX = game.screenToWorld(event.canvasPosition).x;
    final deltaX = eventX - game.player.position.x;

    game.player.position.x += deltaX;
    game.player.nextFruit.position.x += deltaX;

    game.player.nextFruit.release();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (!renderBody) return;

    for (final fixture in body.fixtures) {
      if (fixture.isSensor) continue;

      renderFixture(canvas, fixture);
    }
  }
}
