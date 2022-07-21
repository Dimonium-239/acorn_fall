import 'package:acorn_fall/models/acorn_detals.dart';
import 'package:flutter/material.dart';

class PlayerData extends ChangeNotifier {
  AcornType acornType;
  final List<AcornType> ownedAcorns;
  final int highScore;
  int money;

  PlayerData(
      {required this.acornType,
      required this.ownedAcorns,
      required this.highScore,
      required this.money});

  PlayerData.fromMap(Map<String, dynamic> map)
      : acornType = map['currentAcornType'],
        ownedAcorns = map['ownedAcornsTypes']
            .map((element) => element as AcornType)
            .cast<AcornType>()
            .toList(),
        highScore = map['highScore'],
        money = map['money'];

  static Map<String, dynamic> defaultData = {
    'currentAcornType': AcornType.Pure,
    'ownedAcornsTypes': [],
    'highScore': 0,
    'money': 100,
  };

  bool isOwned(AcornType acornType){
    return ownedAcorns.contains(acornType);
  }

  bool canBuy(AcornType acornType){
    return money >= Acorn.getAcornByType(acornType).cost;
  }

  bool isEquipped(AcornType acornType) {
    return this.acornType == acornType;
  }

  void buy(AcornType acornType) {
    if(canBuy(acornType) && !isOwned(acornType)){
      money -= Acorn.getAcornByType(acornType).cost;
      ownedAcorns.add(acornType);
      notifyListeners();
    }
  }

  void equip(AcornType acornType){
    this.acornType = acornType;
    notifyListeners();
  }
}
