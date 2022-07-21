import 'package:flame/components.dart';

mixin GameScreenSize on Component {
  late Vector2 gameSize;

  void onGameResize(Vector2 size) {
    gameSize = size;
  }
}