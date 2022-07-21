import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/screens/pause_menu.dart';
import 'package:flutter/material.dart';

class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final AcornFallGame gameRef;

  const PauseButton({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
          onPressed: () {
            gameRef.pauseEngine();
            gameRef.overlays.add(PauseMenu.id);
            gameRef.overlays.remove(PauseButton.id);
          },
          child: const Icon(
            Icons.pause,
            color: Colors.white,
          )),
    );
  }
}
