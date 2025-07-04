import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';

void main() {
  runApp(
    GameWidget.controlled(
      gameFactory: WatermelonGame.new,
    ),
  );
}