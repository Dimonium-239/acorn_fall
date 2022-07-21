import 'package:acorn_fall/screens/game_play.dart';
import 'package:acorn_fall/screens/select_acorn.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text('Acorn fall'),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const SelectAcorn()));
                },
                child: const Text('Play')),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {}, child: const Text('Options'))),
        ],
      ),
    ));
  }
}
