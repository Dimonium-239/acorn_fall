import 'package:acorn_fall/models/acorn_detals.dart';
import 'package:acorn_fall/models/player_data.dart';
import 'package:acorn_fall/screens/game_play.dart';
import 'package:acorn_fall/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class SelectAcorn extends StatelessWidget {
  const SelectAcorn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text('Select'),
          ),
          Consumer<PlayerData>(builder: (context, playerData, child) {
            final acorn = Acorn.getAcornByType(playerData.acornType);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Acorn name: ${acorn.name}'),
                Text('Money: ${playerData.money}')
              ],
            );
          }),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: CarouselSlider.builder(
                slideBuilder: (index) {
                  final acorn = Acorn.acorns.entries.elementAt(index).value;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(acorn.assetPath, scale: 4),
                      Text('Speed: ${acorn.speed}'),
                      Text('Level: ${acorn.level}'),
                      Text('Cost: ${acorn.cost}'),
                      Consumer<PlayerData>(
                          builder: (context, playerData, child) {
                        final type = Acorn.acorns.entries.elementAt(index).key;
                        final isEquipped = playerData.isEquipped(type);
                        final isOwned = playerData.isOwned(type);
                        final canBuy = playerData.canBuy(type);

                        return ElevatedButton(
                            onPressed: isEquipped
                                ? null
                                : () {
                                    if (isOwned) {
                                      playerData.equip(type);
                                    } else {
                                      if (canBuy) {
                                        playerData.buy(type);
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  title: const Text(
                                                    'Insufficient balance',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: Text(
                                                    'Need ${acorn.cost - playerData.money} more',
                                                    textAlign: TextAlign.center,
                                                  ));
                                            });
                                      }
                                    }
                                  },
                            child: Text(isEquipped
                                ? 'Equipped'
                                : isOwned
                                    ? 'Select'
                                    : 'Buy'));
                      }),
                    ],
                  );
                },
                itemCount: Acorn.acorns.length),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const GamePlay()));
                },
                child: const Text('Start')),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const MainMenu()));
                  },
                  child: const Icon(Icons.arrow_back_ios_rounded))),
        ],
      ),
    ));
  }
}
