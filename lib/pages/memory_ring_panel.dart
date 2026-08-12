import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/game_images.dart';

/// 게임 화면 전체에 크게 표시되는 미도리 고리
class MemoryRingPanel extends StatefulWidget {
  const MemoryRingPanel({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  State<MemoryRingPanel> createState() => _MemoryRingPanelState();
}

class _MemoryRingPanelState extends State<MemoryRingPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // 미도리들이 아주 천천히 회전하도록 합니다.
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.48),
      child: Center(
        child: Container(
          width: 340,
          height: 500,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(
            18,
            14,
            18,
            18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE7C98B),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // 제목과 닫기 버튼
              Row(
                children: [
                  const SizedBox(width: 48),

                  const Expanded(
                    child: Text(
                      '미도리 고리',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9B5B35),
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: '닫기',
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF9B5B35),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              const Text(
                '같은 미도리끼리 만나면 다음 단계로 성장합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B7155),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final center = Offset(
                      constraints.maxWidth / 2,
                      constraints.maxHeight / 2,
                    );

                    final shortestSide = math.min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    final ringRadius = shortestSide * 0.36;

                    return AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        final rotation =
                            _rotationController.value *
                                2 *
                                math.pi;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 원형 고리와 화살표
                            Positioned.fill(
                              child: CustomPaint(
                                painter: MidoriRingPainter(),
                              ),
                            ),

                            // 고리 중앙 설명
                            Center(
                              child: Container(
                                width: 94,
                                height: 94,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(
                                    alpha: 0.78,
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFE7C98B),
                                    width: 2,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      color: Color(0xFFD27828),
                                      size: 28,
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      '성장 순서',
                                      style: TextStyle(
                                        color: Color(0xFF9B5B35),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 11개의 미도리 이미지
                            for (
                            int index = 0;
                            index < GameImages.fruitCount;
                            index++
                            )
                              _buildLargeFruit(
                                index: index,
                                center: center,
                                ringRadius: ringRadius,
                                rotation: rotation,
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: widget.onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE7A94F),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '게임으로 돌아가기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeFruit({
    required int index,
    required Offset center,
    required double ringRadius,
    required double rotation,
  }) {
    final count = GameImages.fruitCount;

    // 위쪽에서 시작하여 시계 방향으로 배치합니다.
    final angle =
        -math.pi / 2 +
            (2 * math.pi * index / count) +
            rotation;

    // 단계가 높을수록 이미지를 조금 크게 표시합니다.
    final imageSize = (37.0 + index * 1.4).clamp(
      37.0,
      52.0,
    );

    // 원형 이동이 너무 기계적으로 보이지 않도록
    // 각 미도리마다 아주 작은 흔들림을 추가합니다.
    final wave =
        math.sin(rotation * 3 + index * 0.8) * 2.2;

    final x =
        center.dx +
            (ringRadius + wave) * math.cos(angle) -
            imageSize / 2;

    final y =
        center.dy +
            (ringRadius + wave) * math.sin(angle) -
            imageSize / 2;

    return Positioned(
      left: x,
      top: y,
      width: imageSize,
      height: imageSize,
      child: Image.asset(
        GameImages.fruitAsset(index),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          debugPrint(
            '미도리 고리 이미지 로드 실패: '
                '${GameImages.fruitAsset(index)}',
          );
          debugPrint('오류: $error');

          return _FruitErrorView(
            index: index,
          );
        },
      ),
    );
  }
}

/// 게임 화면 오른쪽에 항상 표시되는 작은 미도리 고리
///
/// 이 위젯을 클릭하면 큰 MemoryRingPanel을 열도록
/// 본 게임 파일에서 onTap을 연결합니다.
class MidoriRingPreview extends StatefulWidget {
  const MidoriRingPreview({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<MidoriRingPreview> createState() =>
      _MidoriRingPreviewState();
}

class _MidoriRingPreviewState
    extends State<MidoriRingPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '미도리 고리 크게 보기',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '미도리 고리',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Color(0xFFA06E3C),
                    offset: Offset(-1, 0),
                  ),
                  Shadow(
                    color: Color(0xFFA06E3C),
                    offset: Offset(1, 0),
                  ),
                  Shadow(
                    color: Color(0xFFA06E3C),
                    offset: Offset(0, -1),
                  ),
                  Shadow(
                    color: Color(0xFFA06E3C),
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.76,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFB48855,
                    ).withValues(alpha: 0.22),
                    offset: const Offset(2, 4),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final center = Offset(
                    constraints.maxWidth / 2,
                    constraints.maxHeight / 2,
                  );

                  const ringRadius = 35.0;
                  const imageSize = 19.0;

                  return AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      final rotation =
                          _rotationController.value *
                              2 *
                              math.pi;

                      return Stack(
                        children: [
                          // 작은 원형 안내선
                          Positioned.fill(
                            child: CustomPaint(
                              painter:
                              MidoriRingPreviewPainter(),
                            ),
                          ),

                          // 11개 미도리
                          for (
                          int index = 0;
                          index <
                              GameImages.fruitCount;
                          index++
                          )
                            _buildPreviewFruit(
                              index: index,
                              center: center,
                              ringRadius: ringRadius,
                              imageSize: imageSize,
                              rotation: rotation,
                            ),

                          // 가운데 확대 아이콘
                          Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: 0.88,
                                ),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                size: 22,
                                color: Color(0xFFD27828),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewFruit({
    required int index,
    required Offset center,
    required double ringRadius,
    required double imageSize,
    required double rotation,
  }) {
    final angle =
        -math.pi / 2 +
            (
                2 *
                    math.pi *
                    index /
                    GameImages.fruitCount
            ) +
            rotation;

    final wave =
        math.sin(rotation * 3 + index) * 1.2;

    final x =
        center.dx +
            (ringRadius + wave) * math.cos(angle) -
            imageSize / 2;

    final y =
        center.dy +
            (ringRadius + wave) * math.sin(angle) -
            imageSize / 2;

    return Positioned(
      left: x,
      top: y,
      width: imageSize,
      height: imageSize,
      child: Image.asset(
        GameImages.fruitAsset(index),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _FruitErrorView(
            index: index,
            fontSize: 6,
          );
        },
      ),
    );
  }
}

/// 큰 미도리 고리의 원과 진행 방향을 표시합니다.
class MidoriRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        math.min(size.width, size.height) * 0.36;

    final ringPaint = Paint()
      ..color = const Color(0xFFEBCF8F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      center,
      radius,
      ringPaint,
    );

    // 진행 방향을 표현하는 곡선 화살표
    final arrowPaint = Paint()
      ..color = const Color(0xFF7DBA45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final arrowRect = Rect.fromCircle(
      center: center,
      radius: radius + 12,
    );

    canvas.drawArc(
      arrowRect,
      -math.pi * 0.72,
      math.pi * 0.45,
      false,
      arrowPaint,
    );

    final arrowAngle = -math.pi * 0.27;

    final arrowPoint = Offset(
      center.dx +
          (radius + 12) *
              math.cos(arrowAngle),
      center.dy +
          (radius + 12) *
              math.sin(arrowAngle),
    );

    final arrowHead = Path()
      ..moveTo(
        arrowPoint.dx,
        arrowPoint.dy,
      )
      ..lineTo(
        arrowPoint.dx - 11,
        arrowPoint.dy - 2,
      )
      ..lineTo(
        arrowPoint.dx - 4,
        arrowPoint.dy + 9,
      )
      ..close();

    canvas.drawPath(
      arrowHead,
      Paint()
        ..color = const Color(0xFF7DBA45)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(
      covariant MidoriRingPainter oldDelegate,
      ) {
    return false;
  }
}

/// 작은 미리보기의 원형 안내선입니다.
class MidoriRingPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final ringPaint = Paint()
      ..color = const Color(
        0xFFEBCF8F,
      ).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      center,
      35,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant MidoriRingPreviewPainter oldDelegate,
      ) {
    return false;
  }
}

/// 이미지 로딩 실패 시 표시되는 임시 화면
class _FruitErrorView extends StatelessWidget {
  const _FruitErrorView({
    required this.index,
    this.fontSize = 9,
  });

  final int index;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _fallbackColor(index),
      ),
      child: Text(
        '$index',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Color _fallbackColor(int index) {
  const colors = [
    Color(0xFFE94C62),
    Color(0xFFFF6F7D),
    Color(0xFF8D5AC8),
    Color(0xFFFF9D3B),
    Color(0xFFF28B42),
    Color(0xFFE95D45),
    Color(0xFFF6D46B),
    Color(0xFFFFA8B8),
    Color(0xFFF0C64B),
    Color(0xFF9ACB63),
    Color(0xFF55B95E),
  ];

  return colors[index % colors.length];
}