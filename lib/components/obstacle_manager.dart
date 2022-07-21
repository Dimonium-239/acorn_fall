import 'dart:math';

import 'package:acorn_fall/components/obstacle.dart';
import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/helpers/game_screen_size.dart';
import 'package:acorn_fall/models/obstacle_data.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

class ObstacleManager extends Component
    with GameScreenSize, HasGameRef<AcornFallGame> {
  late Timer _timer;
  late Timer _freezeTimer;
  late List<SpriteSheet> _spriteList;
  final Random _random = Random();

  ObstacleManager({required spriteList}) : super() {
    _timer = Timer(1, onTick: _spawnObstacle, repeat: true);
    _spriteList = spriteList;
    _freezeTimer = Timer(2, onTick: () {
      _timer.start();
    });
  }

  void _spawnObstacle() {
    Vector2 initSize = Vector2(64, 64);
    Vector2 position =
        Vector2(_random.nextDouble() * gameSize.x, gameSize.y + initSize.y);
    position.clamp(Vector2.zero() + initSize / 2, gameSize + initSize);

    final obstacleData = _obstacleDataList.elementAt(_random.nextInt(_obstacleDataList.length));

    Obstacle obstacle = Obstacle(
        sprite: _spriteList.elementAt(obstacleData.spriteId).getSpriteById(0),
        size: initSize,
        position: position,
        speedOfRotation: _random.nextDouble() * 0.05,
        isClockWise: _random.nextBool(),
        obstacleData: obstacleData);
    obstacle.anchor = (Anchor.values..shuffle()).first;
    gameRef.add(obstacle);
  }

  @override
  void onMount() {
    _timer.start();
  }

  @override
  void onRemove() {
    _timer.stop();
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    _freezeTimer.update(dt);
  }

  void reset(){
    _timer.stop();
    _timer.start();
  }

  void freeze(){
    _timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }

  static const List<ObstacleData> _obstacleDataList = [
    ObstacleData(speed: 200, spriteId: 0, level: 1, hMove: false, killPoint: 1),
    ObstacleData(speed: 150, spriteId: 1, level: 4, hMove: true, killPoint: 5),
    ObstacleData(speed: 250, spriteId: 2, level: 2, hMove: false, killPoint: 2),
    ObstacleData(speed: 300, spriteId: 3, level: 3, hMove: false, killPoint: 3),
  ];

}
