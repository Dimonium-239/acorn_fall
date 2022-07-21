import 'dart:math';

import 'package:acorn_fall/components/bullet.dart';
import 'package:acorn_fall/components/obstacle.dart';
import 'package:acorn_fall/components/obstacle_manager.dart';
import 'package:acorn_fall/components/pause_button.dart';
import 'package:acorn_fall/components/player.dart';
import 'package:acorn_fall/components/power_up_manager.dart';
import 'package:acorn_fall/helpers/command.dart';
import 'package:acorn_fall/helpers/game_screen_size.dart';
import 'package:acorn_fall/models/acorn_detals.dart';
import 'package:acorn_fall/models/player_data.dart';
import 'package:acorn_fall/power-ups/power-up.dart';
import 'package:acorn_fall/screens/game_over_menu.dart';
import 'package:acorn_fall/screens/pause_menu.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcornFallGame extends FlameGame
    with HasCollisionDetection, HasTappables, HasDraggables {
  final double _joystickKnobRadius = 25;
  final double _joystickRadius = 60;
  final double _joystickDeadZone = 10;
  Vector2 _tapStartDrag = Vector2.zero();
  Vector2 _tapCurrentDrag = Vector2.zero();

  late final SpriteSheet _bulletSprite;
  late Player _player;
  late CircleComponent _joystick;
  late CircleComponent _joystickKnob;
  late final ObstacleManager _obstacleManager;
  late final PowerUpManager _powerUpManager;

  late TextComponent _playerScore;
  late TextComponent _playerHealth;

  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  int isJoystickBlock = -1;

  bool _isAlreadyLoaded = false;

  late List<SpriteSheet> acornSpriteList;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (!_isAlreadyLoaded) {
      await images.loadAll([
        'acorn.png',
        'acorn_roman.png',
        'asteroid1.png',
        'asteroid2.png',
        'asteroid3.png',
        'asteroid4.png',
        'squirrel.png',
        'nuke.png',
        'drop.png',
        'ice-cube.png',
        'mushroom.png'
      ]);

      _bulletSprite = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('squirrel.png'),
        columns: 1,
        rows: 1,
      );

      List<SpriteSheet> imageList = [
        SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('asteroid1.png'),
          columns: 1,
          rows: 1,
        ),
        SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('asteroid2.png'),
          columns: 1,
          rows: 1,
        ),
        SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('asteroid3.png'),
          columns: 1,
          rows: 1,
        ),
        SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('asteroid4.png'),
          columns: 1,
          rows: 1,
        ),
      ];

      acornSpriteList = [
        SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('acorn.png'),
          columns: 1,
          rows: 1,
        ),
        SpriteSheet.fromColumnsAndRows(
          image: images.fromCache('acorn_roman.png'),
          columns: 1,
          rows: 1,
        ),
      ];

      children.whereType<GameScreenSize>().forEach((element) {
        element.onGameResize(size);
      });

      const acornType = AcornType.Pure;
      final acorn = Acorn.getAcornByType(acornType);

      _player = Player(
        acornType: acornType,
        sprite: acornSpriteList[acorn.spriteId].getSpriteById(0),
        size: Vector2(50, 64),
        position: canvasSize / 2,
      );

      _player.anchor = Anchor.bottomCenter;

      add(_player);

      _obstacleManager = ObstacleManager(spriteList: imageList);
      add(_obstacleManager);

      _powerUpManager = PowerUpManager();
      add(_powerUpManager);

      _playerScore = TextComponent(
          text: 'Score: 0',
          position: Vector2(10, 10),
          textRenderer: TextPaint(style: const TextStyle(fontSize: 16)));

      _playerHealth = TextComponent(
          text: 'Health: 100%',
          position: Vector2(size.x - 12, 10),
          textRenderer: TextPaint(style: const TextStyle(fontSize: 16)));
      _playerHealth.anchor = Anchor.topRight;

      _playerScore.positionType = PositionType.viewport;
      _playerHealth.positionType = PositionType.viewport;

      add(_playerScore);
      add(_playerHealth);
      camera.defaultShakeIntensity = 10;
      _isAlreadyLoaded = true;
    }
  }

  @override
  void onAttach() {
    if (buildContext != null) {
      final playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      _player.setAcornType(playerData.acornType);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _processCommands();
    _playerScore.text = 'Score: ${_player.score}';
    _playerHealth.text = 'Health: ${_player.health}%';

    if (_player.health <= 0 && !camera.shaking) {
      pauseEngine();
      overlays.remove(PauseButton.id);
      overlays.add(GameOverMenu.id);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        Rect.fromLTWH(size.x - 110, 10, _player.health.toDouble(), 20),
        Paint()..color = Colors.redAccent);
    canvas.drawRect(
        Rect.fromLTWH(size.x - 110, 10, 100, 20),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke);
    super.render(canvas);
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void _processCommands() {
    for (var command in _commandList) {
      for (var component in children) {
        command.run(component);
      }
    }
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    children.whereType<GameScreenSize>().forEach((element) {
      element.onGameResize(size);
    });
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (_player.health > 0) {
          pauseEngine();
          overlays.remove(PauseButton.id);
          overlays.add(PauseMenu.id);
        }
        break;
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    Bullet bullet = Bullet(
      sprite: _bulletSprite.getSpriteById(0),
      size: Vector2(32, 32),
      position: _player.position,
    );
    bullet.anchor = Anchor.center;
    add(bullet);

    if(_player.getShootMultipleBullets){
      for (int i = -1; i < 2; i+= 2){
        Bullet bullet = Bullet(
          sprite: _bulletSprite.getSpriteById(0),
          size: Vector2(32, 32),
          position: _player.position,
        );
        bullet.anchor = Anchor.center;
        bullet.direction.rotate(i * pi / 6);
        add(bullet);
      }
    }
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    if (isJoystickBlock == -1) {
      isJoystickBlock = pointerId;
      _player.setMoveDirection(Vector2.zero());
      _tapStartDrag = info.eventPosition.global;
      _joystick = CircleComponent(
          radius: _joystickRadius,
          position: _tapStartDrag,
          paint: Paint()..color = Colors.blueGrey.withOpacity(0.4));
      _joystickKnob = CircleComponent(
          radius: _joystickKnobRadius,
          position: _tapStartDrag,
          paint: Paint()..color = Colors.lightBlue.shade500.withOpacity(0.4));
      _joystick.anchor = Anchor.center;
      _joystickKnob.anchor = Anchor.center;
      add(_joystick);
      add(_joystickKnob);
    }
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    super.onDragUpdate(pointerId, info);
    if (isJoystickBlock == pointerId) {
      _tapCurrentDrag = info.eventPosition.global;
      Vector2 delta = _tapCurrentDrag - _tapStartDrag;
      if (delta.distanceTo(Vector2.zero()) > _joystickRadius) {
        _joystickKnob.position =
            _tapStartDrag + delta.normalized() * _joystickRadius;
      } else {
        _joystickKnob.position = _tapCurrentDrag;
      }
      if (delta.distanceTo(Vector2.zero()) > _joystickDeadZone) {
        _player.setMoveDirection(delta);
      } else {
        _player.setMoveDirection(Vector2.zero());
      }
    }
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    if (isJoystickBlock == pointerId) {
      super.onDragEnd(pointerId, info);
      _player.setMoveDirection(Vector2.zero());
      _joystick.removeFromParent();
      _joystickKnob.removeFromParent();
      isJoystickBlock = -1;
    }
  }

  void reset() {
    _player.reset();
    _obstacleManager.reset();
    _powerUpManager.reset();

    children.whereType<Obstacle>().forEach((obstacle) {
      obstacle.removeFromParent();
    });

    children.whereType<Bullet>().forEach((bullet) {
      bullet.removeFromParent();
    });

    children.whereType<PowerUp>().forEach((powerUp) {
      powerUp.removeFromParent();
    });
  }
}
