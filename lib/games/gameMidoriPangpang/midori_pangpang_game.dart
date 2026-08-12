import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../constants/game_images.dart';
import '../../constants/game_sounds.dart';
import '../../services/game_audio_service.dart';

/// 모바일 프레임 변화와 관계없이 Forge2D 물리를
/// 1/60초 단위로 진행하는 World입니다.
class FixedStepMidoriWorld extends Forge2DWorld {
  static const double fixedStep = 1 / 60;

  // 다시 하기 직후 프레임이 잠시 낮아져도
  // 실제 시간만큼 물리가 따라갈 수 있도록 여유를 늘립니다.
  static const int maxSubSteps = 5;
  static const double maxFrameDt = 0.0833333333;

  double _accumulator = 0;

  void resetAccumulator() {
    _accumulator = 0;
  }

  @override
  void update(double dt) {
    final safeDt =
    dt.clamp(0.0, maxFrameDt).toDouble();

    _accumulator += safeDt;

    int steps = 0;

    while (_accumulator >= fixedStep &&
        steps < maxSubSteps) {
      super.update(fixedStep);
      _accumulator -= fixedStep;
      steps++;
    }

    // 남은 시간이 너무 많이 누적되면 최대 한 프레임 분량만 남깁니다.
    // 기존처럼 전부 0으로 버리지 않아 슬로모션 현상을 줄입니다.
    if (_accumulator > maxFrameDt) {
      _accumulator = maxFrameDt;
    }
  }
}

/// Forge2D 충돌 이벤트 기반 미도리팡팡 엔진
///
/// - 과일/벽 충돌: Forge2D
/// - 같은 과일 병합 감지: ContactCallbacks
/// - 전체 과일 이중 반복문: 사용하지 않음
/// - Python 원본의 mass를 실제 Body 질량으로 환산
class MidoriPangpangGame extends Forge2DGame {
  MidoriPangpangGame()
      : super(
    gravity: Vector2(0, 140),
    zoom: 10,
    world: FixedStepMidoriWorld(),
  ) {
    // 고정 스텝과 함께 과도하지 않은 범위에서
    // 속도/위치 보정 반복을 유지합니다.
    positionIterations = 16;
    velocityIterations = 10;
  }

  static const double worldWidth = 70;
  static const double worldHeight = 75;

  static const double boxLeft = 18;
  static const double boxRight = 52;
  static const double boxBottom = 70;
  static const double boxTop = 14;
  static const double gameOverLine = 16;
  static const double dropY = 8;

  static const double basketWidth = boxRight - boxLeft;
  static const double basketHeight = boxBottom - boxTop;

  static const double mobileViewTop = 5.5;
  static const double mobileViewBottom = boxBottom;
  static const double mobileHorizontalMargin = 2.0;
  static const double mobileVerticalMargin = 1.0;

  static const double mobileViewWidth =
      basketWidth + mobileHorizontalMargin * 2;

  static const double mobileViewHeight =
      (mobileViewBottom - mobileViewTop) +
          mobileVerticalMargin * 2;

  static const double mobileViewAspectRatio =
      mobileViewWidth / mobileViewHeight;

  /// Python 원본의 radius/score/mass를 1/10 축척으로 옮겼습니다.
  ///
  /// mass는 밀도가 아니라 과일 하나의 목표 총질량입니다.
  static const List<FruitInfo> fruitData = [
    FruitInfo(radius: 1.7, score: 1, name: '체리', mass: 1.0),
    FruitInfo(radius: 2.0, score: 3, name: '딸기', mass: 1.8),
    FruitInfo(radius: 2.8, score: 6, name: '포도', mass: 3.2),
    FruitInfo(radius: 3.7, score: 10, name: '귤', mass: 5.5),
    FruitInfo(radius: 4.7, score: 15, name: '감', mass: 8.5),
    FruitInfo(radius: 5.7, score: 21, name: '사과', mass: 13.0),
    FruitInfo(radius: 6.5, score: 28, name: '배', mass: 18.0),
    FruitInfo(radius: 7.2, score: 36, name: '복숭아', mass: 23.0),
    FruitInfo(radius: 8.2, score: 45, name: '파인애플', mass: 30.0),
    FruitInfo(radius: 9.2, score: 55, name: '멜론', mass: 38.0),
    FruitInfo(radius: 10.2, score: 66, name: '수박', mass: 48.0),
  ];

  final math.Random _random = math.Random();
  final List<Sprite> fruitSprites = [];
  final List<FruitBody> _fruits = [];

  final Queue<_MergeRequest> _mergeQueue =
  Queue<_MergeRequest>();
  final Set<FruitBody> _reservedForMerge =
  <FruitBody>{};

  _PendingCreation? _pendingCreation;

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> nextLevel = ValueNotifier<int>(0);
  final ValueNotifier<bool> gameOver =
  ValueNotifier<bool>(false);

  int _currentLevel = 0;
  double _aimX = (boxLeft + boxRight) / 2;
  double _dropCooldown = 0;
  double _overflowTime = 0;

  bool _isReady = false;
  bool _isShuttingDown = false;

  /// 게임 오버 자동 테스트용 임시 설정입니다.
  ///
  /// true: 클릭 없이 과일이 임의 위치에서 계속 떨어집니다.
  /// false: 기존처럼 사용자가 화면을 눌러 과일을 떨어뜨립니다.
  static const bool autoDropTestMode = false;

  @override
  Color backgroundColor() => const Color(0xFFF7E9CC);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final fixedWorld = world;
    if (fixedWorld is FixedStepMidoriWorld) {
      fixedWorld.resetAccumulator();
    }

    final loadedImages = await images.loadAll(
      GameImages.fruitFlamePaths,
    );

    fruitSprites
      ..clear()
      ..addAll(loadedImages.map(Sprite.new));

    _updateCameraForViewport(size);

    _currentLevel = _random.nextInt(4);
    nextLevel.value = _random.nextInt(4);

    await world.add(MidoriBackground());

    await world.addAll([
      BasketWall(
        start: Vector2(boxLeft, 10),
        end: Vector2(boxLeft, boxBottom),
      ),
      BasketWall(
        start: Vector2(boxRight, 10),
        end: Vector2(boxRight, boxBottom),
      ),
      BasketWall(
        start: Vector2(boxLeft, boxBottom),
        end: Vector2(boxRight, boxBottom),
      ),
    ]);

    await world.add(AimGuide(game: this));

    _isReady = true;
    unawaited(_startAudioSafely());

    debugPrint('미도리 Forge2D 충돌 이벤트 엔진 준비 완료');
  }

  Future<void> _startAudioSafely() async {
    try {
      await GameAudioService.instance.initialize(
        GameSounds.all,
      );
      await GameAudioService.instance.playBgm(
        GameSounds.gameBgm,
      );
    } catch (e, stackTrace) {
      debugPrint('미도리 오디오 시작 실패: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateCameraForViewport(size);
  }

  void _updateCameraForViewport(Vector2 viewportSize) {
    if (viewportSize.x <= 0 || viewportSize.y <= 0) {
      return;
    }

    final zoomByWidth =
        viewportSize.x / mobileViewWidth;
    final zoomByHeight =
        viewportSize.y / mobileViewHeight;

    camera.viewfinder
      ..position = Vector2(
        (boxLeft + boxRight) / 2,
        (mobileViewTop + mobileViewBottom) / 2,
      )
      ..anchor = Anchor.center
      ..zoom = math.min(zoomByWidth, zoomByHeight);
  }

  void updateAimFromRatio(double ratio) {
    if (!_isReady ||
        _isShuttingDown ||
        gameOver.value) {
      return;
    }

    final radius = fruitData[_currentLevel].radius;
    final normalized =
    ratio.clamp(0.0, 1.0).toDouble();

    final worldX =
        boxLeft + normalized * basketWidth;

    _aimX = worldX
        .clamp(
      boxLeft + radius,
      boxRight - radius,
    )
        .toDouble();
  }

  void dropFruitAtRatio(double ratio) {
    updateAimFromRatio(ratio);
    dropFruit();
  }

  void dropFruit() {
    if (!_isReady ||
        _isShuttingDown ||
        gameOver.value ||
        _dropCooldown > 0) {
      return;
    }

    final radius = fruitData[_currentLevel].radius;

    final x = _aimX
        .clamp(
      boxLeft + radius,
      boxRight - radius,
    )
        .toDouble();

    final fruit = FruitBody(
      level: _currentLevel,
      initialPosition: Vector2(x, dropY),
    );

    _fruits.add(fruit);
    world.add(fruit);

    GameAudioService.instance.playSfx(
      GameSounds.fruitDrop,
    );

    _currentLevel = nextLevel.value;
    nextLevel.value = _random.nextInt(4);

    // Python 원본의 35프레임과 비슷한 간격
    _dropCooldown = 35 / 60;
  }

  void _dropFruitAutomatically() {
    if (!_isReady ||
        _isShuttingDown ||
        gameOver.value ||
        _dropCooldown > 0) {
      return;
    }

    final radius = fruitData[_currentLevel].radius;
    final minX = boxLeft + radius;
    final maxX = boxRight - radius;

    // 벽 바로 옆을 피하면서 바구니 전체에 고르게 투하합니다.
    _aimX = minX + _random.nextDouble() * (maxX - minX);

    dropFruit();
  }

  /// 실제로 접촉한 같은 단계 과일만 병합 대기열에 넣습니다.
  ///
  /// beginContact 안에서는 World의 Body를 바로 제거하지 않습니다.
  void requestMerge(
      FruitBody first,
      FruitBody second,
      ) {
    if (_isShuttingDown ||
        gameOver.value ||
        first == second ||
        first.level != second.level ||
        first.level >= fruitData.length - 1 ||
        first.isMerging ||
        second.isMerging ||
        first.isRemoving ||
        second.isRemoving ||
        first.isRemoved ||
        second.isRemoved ||
        _reservedForMerge.contains(first) ||
        _reservedForMerge.contains(second)) {
      return;
    }

    first.isMerging = true;
    second.isMerging = true;

    _reservedForMerge
      ..add(first)
      ..add(second);

    _mergeQueue.add(
      _MergeRequest(
        first: first,
        second: second,
      ),
    );
  }

  @override
  void update(double dt) {
    // Forge2D가 먼저 한 프레임의 물리 계산과 충돌 콜백을 처리합니다.
    super.update(dt);

    if (!_isReady || _isShuttingDown) {
      return;
    }

    // 화면 전환/다시 하기 직후 큰 dt가 들어와도
    // 유예 시간과 게임 오버 시간이 한 번에 지나가지 않도록 제한합니다.
    final safeDt = dt.clamp(0.0, 0.05).toDouble();

    if (_dropCooldown > 0) {
      _dropCooldown =
          math.max(0, _dropCooldown - safeDt);
    }

    if (autoDropTestMode &&
        !gameOver.value &&
        _dropCooldown <= 0) {
      _dropFruitAutomatically();
    }

    _removeDisposedFruits();

    // 기존 Body 제거와 새 Body 생성을 같은 물리 스텝에 하지 않도록
    // 단계별로 처리합니다.
    _processPendingCreation();
    _processOneMergeRequest();

    if (!gameOver.value) {
      _updateFruitLifeTimes(safeDt);
      _checkGameOver(safeDt);
    }
  }

  void _removeDisposedFruits() {
    _fruits.removeWhere(
          (fruit) => fruit.isRemoving || fruit.isRemoved,
    );
  }

  void _processOneMergeRequest() {
    if (_pendingCreation != null ||
        _mergeQueue.isEmpty ||
        gameOver.value) {
      return;
    }

    final request = _mergeQueue.removeFirst();
    final first = request.first;
    final second = request.second;

    if (first.isRemoving ||
        second.isRemoving ||
        first.isRemoved ||
        second.isRemoved ||
        !first.isLoaded ||
        !second.isLoaded) {
      _releaseMergeReservation(first, second);
      return;
    }

    final nextLevel = first.level + 1;
    final position =
        (first.body.position + second.body.position) / 2;

    final firstMass = first.info.mass;
    final secondMass = second.info.mass;
    final totalMass = firstMass + secondMass;

    final velocity =
        (first.body.linearVelocity * firstMass +
            second.body.linearVelocity * secondMass) /
            totalMass;

    final angularVelocity =
        (first.body.angularVelocity +
            second.body.angularVelocity) /
            2;

    final safeZoneEntered =
        first.hasEnteredSafeZone ||
            second.hasEnteredSafeZone ||
            position.y - fruitData[nextLevel].radius >
                gameOverLine + 0.5;

    _fruits.remove(first);
    _fruits.remove(second);

    first.removeFromParent();
    second.removeFromParent();

    _pendingCreation = _PendingCreation(
      first: first,
      second: second,
      level: nextLevel,
      position: position,
      velocity: velocity,
      angularVelocity: angularVelocity,
      hasEnteredSafeZone: safeZoneEntered,
      lifeTime: math.max(first.lifeTime, second.lifeTime),
    );
  }

  void _processPendingCreation() {
    final pending = _pendingCreation;

    if (pending == null) {
      return;
    }

    // 두 기존 BodyComponent가 World에서 실제 제거된 뒤 생성합니다.
    if (!pending.first.isRemoved ||
        !pending.second.isRemoved) {
      return;
    }

    _pendingCreation = null;

    final mergedFruit = FruitBody(
      level: pending.level,
      initialPosition: pending.position,
      initialVelocity:
      pending.velocity + Vector2(0, -0.4),
      initialAngularVelocity:
      pending.angularVelocity * 0.45,
      hasEnteredSafeZone:
      pending.hasEnteredSafeZone,
      lifeTime: pending.lifeTime,
    );

    _fruits.add(mergedFruit);
    world.add(mergedFruit);

    score.value += fruitData[pending.level].score;

    GameAudioService.instance.playSfx(
      GameSounds.fruitMerge,
    );

    _releaseMergeReservation(
      pending.first,
      pending.second,
    );
  }

  void _releaseMergeReservation(
      FruitBody first,
      FruitBody second,
      ) {
    _reservedForMerge
      ..remove(first)
      ..remove(second);

    first.isMerging = false;
    second.isMerging = false;
  }

  void _updateFruitLifeTimes(double dt) {
    for (final fruit in _fruits) {
      if (!fruit.isLoaded ||
          fruit.isRemoving ||
          fruit.isRemoved ||
          fruit.isMerging) {
        continue;
      }

      fruit.lifeTime += dt;
    }
  }

  void _checkGameOver(double dt) {
    bool overflow = false;
    bool severeOverflow = false;

    for (final fruit in _fruits) {
      if (!fruit.isLoaded ||
          fruit.isRemoving ||
          fruit.isRemoved ||
          fruit.isMerging) {
        continue;
      }

      // 새로 투하된 과일이 제한선 위에서 시작하는 동안에는
      // 게임 오버로 판단하지 않습니다.
      if (fruit.lifeTime < 0.8) {
        continue;
      }

      final top =
          fruit.body.position.y - fruit.info.radius;

      if (top <= gameOverLine) {
        overflow = true;

        // 제한선을 크게 넘은 상태가 되면 계산량이 더 쌓이기 전에
        // 즉시 게임을 종료합니다.
        if (top <= gameOverLine - 2.0) {
          severeOverflow = true;
        }
      }
    }

    if (severeOverflow) {
      _setGameOver();
      return;
    }

    if (overflow) {
      _overflowTime += dt;

      if (_overflowTime >= 1.0) {
        _setGameOver();
      }
    } else {
      _overflowTime = 0;
    }
  }

  void _setGameOver() {
    if (gameOver.value || _isShuttingDown) {
      return;
    }

    gameOver.value = true;

    unawaited(
      GameAudioService.instance.stopBgm(),
    );

    pauseEngine();
  }

  /// 페이지가 닫히기 전에 호출할 수 있는 명시적 종료 함수입니다.
  void shutdown() {
    if (_isShuttingDown) {
      return;
    }

    _isShuttingDown = true;
    pauseEngine();

    _mergeQueue.clear();
    _reservedForMerge.clear();
    _pendingCreation = null;
  }

  double get aimX => _aimX;
  int get currentLevel => _currentLevel;
  int get fruitCount => _fruits.length;
}

/// 실제 과일 Body
class FruitBody extends BodyComponent<MidoriPangpangGame>
    with ContactCallbacks {
  static const bool showCollisionCircle = false;

  FruitBody({
    required this.level,
    required this.initialPosition,
    this.initialVelocity,
    this.initialAngularVelocity = 0,
    this.hasEnteredSafeZone = false,
    this.lifeTime = 0,
  }) : super(renderBody: false);

  final int level;
  final Vector2 initialPosition;
  final Vector2? initialVelocity;
  final double initialAngularVelocity;

  bool hasEnteredSafeZone;
  double lifeTime;
  bool isMerging = false;

  FruitInfo get info =>
      MidoriPangpangGame.fruitData[level];

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      linearVelocity:
      initialVelocity ?? Vector2.zero(),

      // PC 원본처럼 과일 회전을 허용합니다.
      angularVelocity: initialAngularVelocity,
      angularDamping: 1.8,

      // 정지한 과일은 자동으로 잠들도록 합니다.
      allowSleep: true,

      linearDamping: 0.08,
      userData: this,
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()
      ..radius = info.radius;

    // Pymunk의 mass는 물체 전체 질량입니다.
    // Forge2D의 density는 면적당 질량이므로 면적으로 나눕니다.
    final area =
        math.pi * info.radius * info.radius;
    final density = info.mass / area;

    final fixtureDef = FixtureDef(
      shape,
      density: density,
      friction: 0.6,
      restitution: 0.1,
    );

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void beginContact(
      Object other,
      Contact contact,
      ) {
    if (other is! FruitBody) {
      return;
    }

    game.requestMerge(this, other);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (level < 0 ||
        level >= game.fruitSprites.length) {
      return;
    }

    final radius = info.radius;
    final sprite = game.fruitSprites[level];

    // 물리 원과 이미지 크기를 정확히 일치시킵니다.
    sprite.render(
      canvas,
      position: Vector2(-radius, -radius),
      size: Vector2.all(radius * 2),
      anchor: Anchor.topLeft,
    );

    if (showCollisionCircle) {
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.16
          ..color = const Color(0xFFFF1744),
      );
    }
  }
}

/// 바구니 벽/바닥
class BasketWall
    extends BodyComponent<MidoriPangpangGame> {
  BasketWall({
    required this.start,
    required this.end,
  }) : super(renderBody: false);

  final Vector2 start;
  final Vector2 end;

  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set(start, end);

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.6,
      restitution: 0.1,
    );

    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)
      ..createFixture(fixtureDef);
  }
}

/// 게임 배경
class MidoriBackground extends Component {
  @override
  int get priority => -100;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    const width = MidoriPangpangGame.worldWidth;
    const height = MidoriPangpangGame.worldHeight;

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFFF7E9CC),
    );

    final dotPaint = Paint()
      ..color =
      Colors.white.withValues(alpha: 0.28);

    for (double x = 1.5; x < width; x += 3) {
      for (double y = 1.5; y < height; y += 3) {
        canvas.drawCircle(
          Offset(x, y),
          0.28,
          dotPaint,
        );
      }
    }

    final basketRect = RRect.fromRectAndRadius(
      const Rect.fromLTRB(
        MidoriPangpangGame.boxLeft,
        MidoriPangpangGame.boxTop,
        MidoriPangpangGame.boxRight,
        MidoriPangpangGame.boxBottom,
      ),
      const Radius.circular(1.5),
    );

    canvas.drawRRect(
      basketRect,
      Paint()
        ..color = const Color(0xFFDEC89C)
            .withValues(alpha: 0.38),
    );

    canvas.drawRRect(
      basketRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFD2A541),
    );

    canvas.drawRRect(
      basketRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = const Color(0xFFF8DE7E),
    );

    canvas.drawLine(
      const Offset(
        MidoriPangpangGame.boxLeft + 0.8,
        MidoriPangpangGame.gameOverLine,
      ),
      const Offset(
        MidoriPangpangGame.boxRight - 0.8,
        MidoriPangpangGame.gameOverLine,
      ),
      Paint()
        ..color = const Color(0xFFEF7777)
            .withValues(alpha: 0.70)
        ..strokeWidth = 0.2,
    );
  }
}

/// 투하 위치/현재 과일 표시
class AimGuide extends Component {
  AimGuide({required this.game});

  final MidoriPangpangGame game;

  @override
  // 다음에 나올 과일/조준선은 실제로 떨어지는 과일보다
  // 뒤쪽 레이어에 표시합니다.
  //
  // 배경(-100)보다는 앞, FruitBody(기본 0)보다는 뒤입니다.
  int get priority => -10;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (game.gameOver.value ||
        game.currentLevel < 0 ||
        game.currentLevel >=
            game.fruitSprites.length) {
      return;
    }

    final x = game.aimX;
    final level = game.currentLevel;
    final info =
    MidoriPangpangGame.fruitData[level];

    canvas.drawLine(
      Offset(x, 9.8),
      Offset(x, MidoriPangpangGame.boxBottom),
      Paint()
        ..color =
        Colors.white.withValues(alpha: 0.82)
        ..strokeWidth = 0.18,
    );

    game.fruitSprites[level].render(
      canvas,
      position: Vector2(
        x - info.radius,
        MidoriPangpangGame.dropY - info.radius,
      ),
      size: Vector2.all(info.radius * 2),
      anchor: Anchor.topLeft,
    );
  }
}

class _MergeRequest {
  const _MergeRequest({
    required this.first,
    required this.second,
  });

  final FruitBody first;
  final FruitBody second;
}

class _PendingCreation {
  const _PendingCreation({
    required this.first,
    required this.second,
    required this.level,
    required this.position,
    required this.velocity,
    required this.angularVelocity,
    required this.hasEnteredSafeZone,
    required this.lifeTime,
  });

  final FruitBody first;
  final FruitBody second;
  final int level;
  final Vector2 position;
  final Vector2 velocity;
  final double angularVelocity;
  final bool hasEnteredSafeZone;
  final double lifeTime;
}

class FruitInfo {
  const FruitInfo({
    required this.radius,
    required this.score,
    required this.name,
    required this.mass,
  });

  final double radius;
  final int score;
  final String name;

  /// Python/Pymunk 원본에서 사용한 과일 하나의 총질량
  final double mass;
}
