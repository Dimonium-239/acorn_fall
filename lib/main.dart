import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/models/player_data.dart';
import 'package:acorn_fall/screens/main_menu.dart';
import 'package:flame/flame.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();

  runApp(ChangeNotifierProvider(
    create: (context) => PlayerData.fromMap(PlayerData.defaultData),
    child: MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const MainMenu(),
    ),
  ));
}
