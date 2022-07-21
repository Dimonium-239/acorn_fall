import 'package:acorn_fall/components/obstacle.dart';
import 'package:acorn_fall/components/obstacle_manager.dart';
import 'package:acorn_fall/components/player.dart';
import 'package:acorn_fall/components/power_up_manager.dart';
import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/helpers/command.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

abstract class PowerUp extends SpriteComponent
    with HasGameRef<AcornFallGame>, CollisionCallbacks {
  late Timer _timer;

  Sprite getSprite();
  void onActivated();

  PowerUp({Vector2? position, Vector2? size, Sprite? sprite})
      : super(position: position, size: size, sprite: sprite) {
    _timer = Timer(3, onTick: () {
      removeFromParent();
    });
  }

  @override
  void update(double dt) {
    _timer.update(dt);
  }

  @override
  void onMount() {
    final shape = CircleHitbox();
    add(shape);

    sprite = getSprite();

    _timer.start();
    super.onMount();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      onActivated();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}

class Nuke extends PowerUp {
  Nuke({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return Sprite(gameRef.images.fromCache('nuke.png'));
  }

  @override
  void onActivated() {
    final command = Command<Obstacle>(action: (obstacle) {
      obstacle.destroy();
    });

    gameRef.addCommand(command);
  }
}

class Health extends PowerUp {
  Health({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return Sprite(gameRef.images.fromCache('drop.png'));
  }

  @override
  void onActivated() {
    final command = Command<Player>(action: (player) {
      player.increaseHealthBy(10);
    });

    gameRef.addCommand(command);
  }
}

class Freeze extends PowerUp {
  Freeze({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return Sprite(gameRef.images.fromCache('ice-cube.png'));
  }

  @override
  void onActivated() {
    final commandObstacle = Command<Obstacle>(action: (obstacle) {
      obstacle.freeze();
    });
    gameRef.addCommand(commandObstacle);

    final powerUpManager = Command<PowerUpManager>(action: (powerUpManager) {
      powerUpManager.freeze();
    });
    gameRef.addCommand(powerUpManager);

    final commandObstacleManager =
        Command<ObstacleManager>(action: (obstacleManager) {
      obstacleManager.freeze();
    });
    gameRef.addCommand(commandObstacleManager);
  }
}

class MultiFire extends PowerUp {
  MultiFire({Vector2? position, Vector2? size})
      : super(position: position, size: size);

  @override
  Sprite getSprite() {
    return Sprite(gameRef.images.fromCache('mushroom.png'));
  }

  @override
  void onActivated() {
    final command = Command<Player>(action: (player) {
      player.shootMultipleBullets();
    });
    gameRef.addCommand(command);
  }
}
