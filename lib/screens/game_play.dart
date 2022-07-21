import 'package:acorn_fall/components/pause_button.dart';
import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/screens/game_over_menu.dart';
import 'package:acorn_fall/screens/pause_menu.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

AcornFallGame _acornFallGame = AcornFallGame();

class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async => false,
          child: GameWidget(
            game: _acornFallGame,
            initialActiveOverlays: const [PauseButton.id],
            overlayBuilderMap: {
              PauseButton.id: (BuildContext context, AcornFallGame gameRef) =>
                  PauseButton(
                    gameRef: gameRef,
                  ),
              PauseMenu.id: (BuildContext context, AcornFallGame gameRef) =>
                  PauseMenu(
                    gameRef: gameRef,
                  ),
              GameOverMenu.id: (BuildContext context, AcornFallGame gameRef) =>
                  GameOverMenu(
                    gameRef: gameRef,
                  )
            },
          )),
    );
  }
}
