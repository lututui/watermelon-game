import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';

class GameOverOverlay extends StatelessWidget {
  final WatermelonGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Game Over!", style: TextStyle(fontSize: 30)),
          ),
          Text("Score: ${game.score.value}"),
          ElevatedButton(
            onPressed: () {
              game.overlays.remove(GameOverOverlayConstants.gameOverOverlayId);
              game.resetGame();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.replay),
                ),
                Text("Play Again"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameOverOverlayConstants {
  static const String gameOverOverlayId = 'GameOver';

  GameOverOverlayConstants._();
}
