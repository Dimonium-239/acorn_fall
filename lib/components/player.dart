import 'dart:math';

import 'package:acorn_fall/components/obstacle.dart';
import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/helpers/game_screen_size.dart';
import 'package:acorn_fall/models/acorn_detals.dart';
import 'package:acorn_fall/models/player_data.dart';
import 'package:flame/assets.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:provider/provider.dart';

class Player extends SpriteComponent
    with HasGameRef<AcornFallGame>, GameScreenSize, CollisionCallbacks {
  Vector2 _moveDirection = Vector2.zero();
  final Random _random = Random();
  final Images _images = Images();

  int _score = 0;
  int get score => _score;

  int _health = 100;
  int get health => _health;

  AcornType acornType;
  Acorn _acorn;

  late PlayerData _playerData;
  bool _shootMultipleBullets = false;

  late Timer _powerUpTimer;

  Player({
    required this.acornType,
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : _acorn = Acorn.getAcornByType(acornType), super(sprite: sprite, position: position, size: size){
    _powerUpTimer = Timer(4, onTick: () {
      _shootMultipleBullets = false;
    });
  }

  @override
  Future<void> onLoad() async {
    await _images.load('oak-leaf.jpg');
  }

  @override
  void onMount() {
    super.onMount();
    final shape = CircleHitbox();
    add(shape);

    _playerData = Provider.of<PlayerData>(gameRef.buildContext!, listen: false);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Obstacle) {
      gameRef.camera.shake();
      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _powerUpTimer.update(dt);
    position += _moveDirection.normalized() * _acorn.speed * dt;
    position.clamp(Vector2.zero() + size / 2, gameSize - size / 2);
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 1,
        lifespan: 0.6,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: position.clone() - Vector2((_random.nextDouble() * size.x) - size.x/2, size.y),
          child: ImageParticle(
              image: _images.fromCache('oak-leaf.jpg'),
              size: Vector2(10, 10),
              lifespan: 0.2),
        ),
      ),
    );

    gameRef.add(particleComponent);
  }

  void setMoveDirection(Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 50;
  }

  void addToScore(int points){
    _score += points;
    _playerData.money += points ~/ 10;
  }

  void reset(){
    _score = 0;
    _health = 100;
    position = gameRef.canvasSize / 2;
  }

  void setAcornType(AcornType acornType){
    this.acornType = acornType;
    _acorn = Acorn.getAcornByType(acornType);
    sprite = gameRef.acornSpriteList[_acorn.spriteId].getSpriteById(0);
  }

  void increaseHealthBy(int points){
    _health += points;
    if(_health > 100) {
      _health = 100;
    }
  }

  void shootMultipleBullets(){
    _shootMultipleBullets = true;
    _powerUpTimer.stop();
    _powerUpTimer.start();
  }

  bool get getShootMultipleBullets {
    return _shootMultipleBullets;
  }

}
