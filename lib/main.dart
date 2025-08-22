import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';
import 'package:watermelon_game/overlay/game_over.dart';
import 'package:watermelon_game/overlay/pause.dart';
import 'package:watermelon_game/overlay/score.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await windowManager.setSize(const Size(450, 600));
  await windowManager.setResizable(false);
  await windowManager.setMaximizable(false);
  await windowManager.show();

  runApp(Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'The Fruit Star'),
      home: Scaffold(
        body: GameWidget<WatermelonGame>.controlled(
          gameFactory: WatermelonGame.new,
          overlayBuilderMap: {
            ScoreOverlay.overlayId:
                (_, game) => ScoreOverlay(game: game),
            GameOverOverlay.overlayId:
                (_, game) => GameOverOverlay(game: game),
            PauseOverlay.overlayId:
                (_, game) => PauseOverlay(game: game),
          },
          initialActiveOverlays: [ScoreOverlay.overlayId],
        ),
      ),
    );
  }
}
