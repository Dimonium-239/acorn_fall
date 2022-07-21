import 'dart:math';

import 'package:acorn_fall/components/obstacle.dart';
import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/helpers/game_screen_size.dart';
import 'package:acorn_fall/power-ups/power-up.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

enum PowerUpTypes { health, freeze, nuke, multiFire }

class PowerUpManager extends Component
    with GameScreenSize, HasGameRef<AcornFallGame> {
  late Timer _spawnTimer;
  late Timer _freezeTimer;
  late List<SpriteSheet> _spriteList;
  final Random _random = Random();

  static Map<PowerUpTypes, PowerUp Function(Vector2 position, Vector2 size)>
      _powerUpMap = {
    PowerUpTypes.health: (position, size) =>
        Health(position: position, size: size),
    PowerUpTypes.freeze: (position, size) =>
        Freeze(position: position, size: size),
    PowerUpTypes.nuke: (position, size) => Nuke(position: position, size: size),
    PowerUpTypes.multiFire: (position, size) =>
        MultiFire(position: position, size: size),
  };

  PowerUpManager() : super() {
    _spawnTimer = Timer(5, onTick: _spawnPowerUp, repeat: true);
    _freezeTimer = Timer(2, onTick: () {
      _spawnTimer.start();
    });
  }

  void _spawnPowerUp() {
    Vector2 initSize = Vector2(64, 64);
    Vector2 position = Vector2(
        _random.nextDouble() * gameSize.x, _random.nextDouble() * gameSize.y);
    position.clamp(Vector2.zero() + initSize / 2, gameSize + initSize);

    int randomIndex = _random.nextInt(PowerUpTypes.values.length);

    final selectedPowerUp =
        _powerUpMap[PowerUpTypes.values.elementAt(randomIndex)];

    var powerUp = selectedPowerUp?.call(position, initSize);

    powerUp?.anchor = Anchor.center;
    if (powerUp != null) {
      gameRef.add(powerUp);
    }
  }

  @override
  void onMount() {
    _spawnTimer.start();
  }

  @override
  void onRemove() {
    _spawnTimer.stop();
  }

  @override
  void update(double dt) {
    _spawnTimer.update(dt);
    _freezeTimer.update(dt);
  }

  void reset() {
    _spawnTimer.stop();
    _spawnTimer.start();
  }

  void freeze() {
    _spawnTimer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
