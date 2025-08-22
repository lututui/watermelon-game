import 'package:flutter/material.dart';
import 'package:watermelon_game/game.dart';

class PauseOverlay extends StatelessWidget {
  final WatermelonGame game;
  static const String overlayId = 'Pause';

  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.pink[400]!, width: 4.0),
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.pink[100]!.withAlpha(100),
        ),
        padding: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
          maxHeight: 100,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove(overlayId);
                  game.resumeEngine();
                },
                style: ElevatedButton.styleFrom(shape: CircleBorder()),
                child: Icon(Icons.close),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Paused", style: TextStyle(fontSize: 30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
