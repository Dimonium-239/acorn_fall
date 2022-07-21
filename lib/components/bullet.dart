import 'package:acorn_fall/components/obstacle.dart';
import 'package:acorn_fall/helpers/game_screen_size.dart';
import 'package:acorn_fall/helpers/helpers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent with GameScreenSize, CollisionCallbacks {
  final double _speed = 450;
  double _rotateAngle = 0;
  Vector2 direction = Vector2(0, 1);

  Bullet({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size);

  @override
  void onMount() {
    super.onMount();
    final shape = CircleHitbox();
    add(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Obstacle) {
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    position += direction * _speed * dt;
    _rotateAngle = Helpers.rotator(_rotateAngle, 0.04);
    angle = _rotateAngle;
    if (position.y > gameSize.y) {
      removeFromParent();
    }
  }
}
