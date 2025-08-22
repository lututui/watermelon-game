import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';

class ScoreOverlayWidget extends StatelessWidget {
  final WatermelonGame game;

  const ScoreOverlayWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 100, maxHeight: 20),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: game.score,
                builder: (context, score, _) {
                  return Text(score.toString());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreOverlayConstants {
  static const String overlayId = 'Score';

  ScoreOverlayConstants._();
}
