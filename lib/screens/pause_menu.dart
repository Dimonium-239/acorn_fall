import 'package:acorn_fall/components/pause_button.dart';
import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/screens/main_menu.dart';
import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  static const String id = 'PauseMenu';
  final AcornFallGame gameRef;

  const PauseMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text('Paused'),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
                onPressed: () {
                  gameRef.resumeEngine();
                  gameRef.overlays.remove(PauseMenu.id);
                  gameRef.overlays.add(PauseButton.id);
                },
                child: const Text('Resume')),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    gameRef.overlays.remove(PauseMenu.id);
                    gameRef.overlays.add(PauseButton.id);
                    gameRef.reset();
                    gameRef.resumeEngine();
                  },
                  child: const Text('Restart'))),
          SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    gameRef.resumeEngine();
                    gameRef.overlays.remove(PauseMenu.id);
                    gameRef.reset();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const MainMenu()));
                  },
                  child: const Text('Exit'))),
        ],
      ),
    );
  }
}
