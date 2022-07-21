import 'dart:math';

import 'package:acorn_fall/components/bullet.dart';
import 'package:acorn_fall/components/player.dart';
import 'package:acorn_fall/game.dart';
import 'package:acorn_fall/helpers/command.dart';
import 'package:acorn_fall/helpers/game_screen_size.dart';
import 'package:acorn_fall/helpers/helpers.dart';
import 'package:acorn_fall/models/obstacle_data.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class Obstacle extends SpriteComponent
    with HasGameRef<AcornFallGame>, GameScreenSize, CollisionCallbacks {
  double _speed = 250;
  double _rotateAngle = 0;
  late double _speedOfRotation;
  late final double _savedSpeedOfRotation;
  late final bool _isClockWise;
  late Timer _freezeTimer;
  final Random _random = Random();
  final ObstacleData obstacleData;
  Vector2 moveDirection = Vector2(0, -1);

  Obstacle({
    required Sprite? sprite,
    required ObstacleData this.obstacleData,
    required Vector2? position,
    required Vector2? size,
    required double? speedOfRotation,
    required bool? isClockWise,
  }) : super(sprite: sprite, position: position, size: size) {
    _speed = obstacleData.speed;
    _speedOfRotation = speedOfRotation!;
    _savedSpeedOfRotation = speedOfRotation;
    _isClockWise = isClockWise!;
    _freezeTimer = Timer(2, onTick: () {
      _speed = obstacleData.speed;
      _speedOfRotation = _savedSpeedOfRotation;
    });
    if(obstacleData.hMove){
      moveDirection = getRandomDirection();
    }
  }

  @override
  void onMount() {
    super.onMount();
    final shape = CircleHitbox();
    add(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Bullet || other is Player) {
      destroy();
    }
  }

  void destroy(){
    removeFromParent();

    final command = Command<Player>(action: (player) {
      player.addToScore(10);
    });
    gameRef.addCommand(command);

    final particleComponent = ParticleSystemComponent(
        particle: Particle.generate(
          count: 30,
          lifespan: 0.25,
          generator: (i) => AcceleratedParticle(
            acceleration: getRandomVector(),
            speed: getRandomVector(),
            position: position.clone() - Vector2(0, size.y / 3),
            child: CircleParticle(
              paint: Paint()..color = Colors.white24,
              radius: 2.5,
            ),
          ),
        ));

    gameRef.add(particleComponent);
  }

  @override
  void update(double dt) {
    _freezeTimer.update(dt);
    position += Vector2(0, -1) * _speed * dt;
    _rotateAngle =
        Helpers.rotator(_rotateAngle, _speedOfRotation, _isClockWise);
    angle = _rotateAngle;
    if (position.y < -size.y) {
      removeFromParent();
    } else if(position.x < size.x / 2 || position.x > gameSize.x - size.x / 2){
      moveDirection.x += -1;
    }
  }

  @override
  void onRemove() {
    // print('Removing ${toString()}');
  }

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Vector2 getRandomDirection() {
    return (Vector2.random(_random) - Vector2(0.5, -1)).normalized();
  }

  void freeze(){
    _speed = 0;
    _speedOfRotation = 0;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
