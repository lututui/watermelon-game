import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await windowManager.setSize(const Size(450, 600));
  await windowManager.setResizable(false);
  await windowManager.setMaximizable(false);
  await windowManager.show();

  runApp(GameWidget.controlled(gameFactory: WatermelonGame.new));
}
