import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_game/fruit.dart';
import 'package:watermelon_game/game.dart';

class Bucket extends BodyComponent<WatermelonGame>
    with TapCallbacks, DragCallbacks, ContactCallbacks {
  static final double xBound = 20;
  static final double yOffset = 4;
  static final double yBound = 16;
  static final double dxBound = 0.5;
  static final double dyBound = 0.5;

  final Timer _spawnTimer = Timer(2, autoStart: false);
  late final Fixture sensor;

  Bucket()
    : super(
        paint:
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
      );

  void createFixture(Body body) {
    final topL = Vector2(-xBound, yOffset - yBound);
    final botL = Vector2(-xBound, yOffset + yBound);
    final topR = Vector2(xBound, yOffset - yBound);
    final botR = Vector2(xBound, yOffset + yBound);

    final rightward = Vector2(dxBound, 0);
    final upward = Vector2(0, -dyBound);

    final shapes = [
      [topL, botL, botL + rightward, topL + rightward], // left
      [botL, botR, botR + upward, botL + upward], // bottom
      [botR, botR + rightward, topR + rightward, topR], // right
    ];

    for (var shape in shapes) {
      body.createFixture(FixtureDef(PolygonShape()..set(shape), friction: 1));
    }

    final sensorShape = [topL, botL, botR, topR];

    sensor = body.createFixture(
      FixtureDef(PolygonShape()..set(sensorShape), isSensor: true),
    );
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2.zero(),
      type: BodyType.static,
      userData: this,
    );

    final body = world.createBody(bodyDef);

    createFixture(body);

    return body;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (_spawnTimer.isRunning()) return;
    if (game.player.nextFruit == null) return;

    game.player.updatePosition(deltaPos: event.canvasDelta.x / 10);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (_spawnTimer.isRunning()) return;
    if (game.player.nextFruit == null) return;

    dropFruit();
  }

  void dropFruit() {
    _spawnTimer.start();

    game.player.nextFruit!.release();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (_spawnTimer.isRunning()) return;
    if (game.player.nextFruit == null) return;

    game.player.updatePosition(
      newPos: game.screenToWorld(event.canvasPosition).x,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (_spawnTimer.isRunning()) return;
    if (game.player.nextFruit == null) return;

    dropFruit();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer.update(dt);

    if (_spawnTimer.finished && game.player.nextFruit == null) {
      game.player.nextFruit = FruitType.random(game.player.position);
      world.add(game.player.nextFruit!);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!renderBody) return;

    for (final fixture in body.fixtures) {
      if (fixture.isSensor) continue;

      renderFixture(canvas, fixture);
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    //
  }
}
