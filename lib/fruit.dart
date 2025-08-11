import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:watermelon_game/bucket.dart';
import 'package:watermelon_game/game.dart';

enum FruitType {
  blueberry(0.9, true),
  strawberry(1.5, true),
  orange(2.0, true),
  lime(2.5, true),
  peach(3.0, true),
  apple(3.5, false),
  coconut(4.0, false),
  pomegranate(4.5, false),
  cantaloupe(5.0, false),
  watermelon(5.5, false);

  final double radius;
  final bool spawnable;

  const FruitType(this.radius, this.spawnable);

  Fruit create(Vector2 position, {bool isStatic = true}) {
    return Fruit.asset(
      type: this,
      startingPosition: position,
      isStatic: isStatic,
    );
  }

  static final List<FruitType> spawnableFruit =
      FruitType.values.where((it) => it.spawnable).toList();

  static Fruit random(Vector2 position) {
    return spawnableFruit.random().create(position);
  }

  @override
  String toString() {
    return name;
  }

  FruitType? nextFruitType() {
    return FruitType.values.elementAtOrNull(index + 1);
  }

  int get score {
    return 1 << index;
  }
}

class Fruit extends BodyComponent<WatermelonGame> with ContactCallbacks {
  final FruitType type;
  final Vector2 startingPosition;

  bool markedForMerge = false;
  bool firstTick = true;
  Fruit? _other;
  bool isStatic;
  bool insideBox = false;

  final Timer _outsideBoxTimer = Timer(2, autoStart: false);

  Sprite get sprite {
    return Sprite(game.images.fromCache("fruit/${type.name}.png"))
      ..paint = (Paint()..filterQuality = FilterQuality.high);
  }

  Fruit.asset({
    required this.type,
    required this.startingPosition,
    this.isStatic = true,
  }) : super(renderBody: false);

  void createFixture(Body body) {
    if (body.fixtures.isNotEmpty) {
      for (var fixture in [...body.fixtures]) {
        body.destroyFixture(fixture);
      }

      for (var child in [...children]) {
        remove(child);
      }
    }

    body.createFixture(
      FixtureDef(
        CircleShape(radius: type.radius),
        restitution: 0.2,
        friction: 0.5,
      ),
    );

    add(
      SpriteComponent(
        sprite: sprite,
        size: Vector2.all(2.0 * type.radius),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: isStatic ? BodyType.static : BodyType.dynamic,
      position: startingPosition,
      userData: this,
      active: !isStatic,
    );

    final fruit = world.createBody(bodyDef);

    createFixture(fruit);

    return fruit;
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Bucket) return;

    if (other.sensor != contact.fixtureA && other.sensor != contact.fixtureB) {
      return;
    }

    insideBox = false;
    _outsideBoxTimer.start();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Fruit) {
      beginContactWithOtherFruit(other);
    } else if (other is Bucket) {
      beginContactWithBucket(other, contact);
    }
  }

  void beginContactWithBucket(Bucket bucket, Contact contact) {
    if (insideBox) return;

    if (bucket.sensor != contact.fixtureA &&
        bucket.sensor != contact.fixtureB) {
      return;
    }

    insideBox = true;
    _outsideBoxTimer.stop();
  }

  void beginContactWithOtherFruit(Fruit otherFruit) {
    // Other fruit cannot merge with this one
    if (otherFruit.type != type) return;

    if (markedForMerge) return;
    if (otherFruit.markedForMerge) return;

    if (kDebugMode) {
      print('marking $this for merge');
    }

    markedForMerge = true;
    _other = otherFruit;
  }

  @override
  String toString() {
    return "Instance $hashCode of 'Fruit'";
  }

  @override
  void update(double dt) {
    _outsideBoxTimer.update(dt);

    if (_outsideBoxTimer.finished) {
      game.gameOver = true;
      return;
    }

    if (firstTick) {
      game.player.updatePosition();
      firstTick = false;
      return;
    }

    if (markedForMerge) {
      if (game.mergeCooldown.isRunning()) return;

      if (_other!.parent == null) {
        markedForMerge = false;
        return;
      }

      final nextFruitType = type.nextFruitType();
      final nextFruitPosition = (_other!.position + position) / 2.0;

      if (kDebugMode) {
        print(nextFruitPosition);
      }

      world.destroyBody(_other!.body);
      world.remove(_other!);

      world.destroyBody(body);
      world.remove(this);

      if (nextFruitType != null) {
        world.add(nextFruitType.create(nextFruitPosition, isStatic: false));

        markedForMerge = false;
        _other = null;
      }

      game.score += type.score;
      game.mergeCooldown.start();

      return;
    }
  }

  void release() {
    isStatic = false;
    world.destroyBody(body);
    body = createBody();
    _outsideBoxTimer.start();

    game.player.nextFruit = null;
  }
}
