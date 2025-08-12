import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_game/fruit.dart';
import 'package:watermelon_game/game.dart';

class Bucket extends BodyComponent<WatermelonGame>
    with TapCallbacks, DragCallbacks, ContactCallbacks {
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
    final rightward = Vector2(BucketConstants.widthX, 0);
    final upward = Vector2(0, -BucketConstants.widthY);

    final shapes = [
      [
        BucketConstants.topLeftPoint,
        BucketConstants.bottomLeftPoint,
        BucketConstants.bottomLeftPoint + rightward,
        BucketConstants.topLeftPoint + rightward,
      ], // left
      [
        BucketConstants.bottomLeftPoint,
        BucketConstants.bottomRightPoint,
        BucketConstants.bottomRightPoint + upward,
        BucketConstants.bottomLeftPoint + upward,
      ], // bottom
      [
        BucketConstants.bottomRightPoint,
        BucketConstants.bottomRightPoint + rightward,
        BucketConstants.topRightPoint + rightward,
        BucketConstants.topRightPoint,
      ], // right
    ];

    for (var shape in shapes) {
      body.createFixture(FixtureDef(PolygonShape()..set(shape), friction: 1));
    }

    final sensorShape = [
      BucketConstants.topLeftPoint,
      BucketConstants.bottomLeftPoint,
      BucketConstants.bottomRightPoint,
      BucketConstants.topRightPoint,
    ];

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

    game.player.updatePosition(
      deltaPos: event.canvasDelta.x / WatermelonGameConstants.zoom,
    );
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
}

class BucketConstants {
  static const double lengthX = 20;
  static const double lengthY = 16;

  static const double offsetY = 6;

  static const double widthX = 0.5;
  static const double widthY = 0.5;

  static final Vector2 topLeftPoint = Vector2(-lengthX, -lengthY + offsetY);
  static final Vector2 topRightPoint = Vector2(lengthX, -lengthY + offsetY);

  static final Vector2 bottomLeftPoint = Vector2(-lengthX, lengthY + offsetY);
  static final Vector2 bottomRightPoint = Vector2(lengthX, lengthY + offsetY);

  BucketConstants._();
}
