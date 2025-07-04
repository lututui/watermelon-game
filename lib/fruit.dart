import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
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
  final bool spawnableByPlayer;

  const FruitType(this.radius, this.spawnableByPlayer);

  Fruit create(Vector2 position) {
    return Fruit.asset(type: this, position: position);
  }

  static Fruit random(Vector2 position) {
    return FruitType.values
        .where((it) => it.spawnableByPlayer)
        .toList()
        .random()
        .create(position);
  }

  @override
  String toString() {
    return name;
  }

  FruitType? nextFruitType() {
    return FruitType.values.elementAtOrNull(index + 1);
  }
}

class Fruit extends BodyComponent<WatermelonGame> with ContactCallbacks {
  FruitType type;
  bool markedForMerge = false;
  Fruit? _other;

  @override
  final Vector2 position;

  Sprite get sprite {
    return Sprite(game.images.fromCache("${type.name}.png"));
  }

  Fruit.asset({required this.type, required this.position})
    : super(renderBody: false);

  void createFixture(Body body) {
    if (body.fixtures.isNotEmpty) {
      for (var fixture in [...body.fixtures]) {
        body.destroyFixture(fixture);
      }

      for (var child in [...children]) {
        remove(child);
      }
    }

    body.createFixture(FixtureDef(CircleShape(radius: type.radius)));

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
      type: BodyType.dynamic,
      position: position,
      userData: this,
    );

    final fruit = world.createBody(bodyDef);

    createFixture(fruit);

    return fruit;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Fruit) return;
    if (other.type != type) return;

    if (markedForMerge) return;
    if (other.markedForMerge) return;

    print('marking $this for merge');

    markedForMerge = true;
    _other = other;
  }

  @override
  String toString() {
    return "Instance $hashCode of 'Fruit'";
  }

  @override
  void update(double dt) {
    if (!markedForMerge) return;
    if (game.mergeCooldown.isRunning()) return;

    final nextFruitType = type.nextFruitType();

    world.destroyBody(_other!.body);
    world.remove(_other!);

    if (nextFruitType == null) {
      world.destroyBody(body);
      world.remove(this);
    } else {
      type = nextFruitType;
      createFixture(body);

      markedForMerge = false;
      _other = null;
    }

    game.mergeCooldown.start();
  }
}
