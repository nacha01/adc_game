import 'dart:async';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../constants/game_images.dart';
import '../../constants/game_sounds.dart';
import '../../models/game_info.dart';
import '../../pages/memory_ring_panel.dart';
import '../../services/game_audio_service.dart';
import '../../services/ranking_service.dart';
import '../../services/user_session.dart';
import '../../pages/game_result_page.dart';
import 'midori_page_controller.dart';
import 'midori_pangpang_game.dart';
import '../../widgets/game_audio_settings_dialog.dart';

/// 미도리팡 Flutter 페이지
///
/// 물리 처리는 Flame + Forge2D가 담당하고,
/// 점수/다음 과일/게임오버 UI는 Flutter 위젯으로 표시합니다.
class GameMidoriPangpang extends StatefulWidget {
  final GameInfo gameInfo;

  const GameMidoriPangpang({super.key, required this.gameInfo});

  @override
  State<GameMidoriPangpang> createState() => _GameMidoriPangpangState();
}

class _GameMidoriPangpangState extends State<GameMidoriPangpang> {
  late MidoriPangpangGame _game;
  late final MidoriPageController _pageController;
  int _myBestScore = 0;

  @override
  void initState() {
    super.initState();

    _game = MidoriPangpangGame();
    _pageController = MidoriPageController();
    _pageController.addListener(_refreshPage);
    _game.gameOver.addListener(_handleGameOver);

    unawaited(_loadMyBestScore());
  }

  Future<void> _loadMyBestScore() async {
    final userId = UserSession.userId;

    if (!UserSession.isLoggedIn || userId == null) {
      return;
    }

    final result =
    await RankingService.instance.getMyBestScore(
      userId: userId,
      gameCode: widget.gameInfo.id,
    );

    if (!mounted || !result.success) {
      return;
    }

    setState(() {
      _myBestScore = result.score;
    });
  }

  void _refreshPage() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleGameOver() {
    if (!_game.gameOver.value) {
      return;
    }

    if (!_pageController.beginResultNavigation()) {
      return;
    }

    unawaited(_openResultPage());
  }

  Future<void> _openResultPage() async {
    final finalScore = _game.score.value;

    // 이전 게임 Route가 입력을 계속 잡지 않도록
    // 엔진과 병합 대기 상태를 먼저 완전히 종료합니다.
    _game.shutdown();

    unawaited(
      GameAudioService.instance.stopBgm(),
    );

    if (!mounted) {
      return;
    }

    // Flame update/listener 실행 도중 바로 Navigator를 변경하지 않고
    // 현재 Flutter 프레임이 끝난 다음 결과 화면으로 교체합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement<void, void>(
        PageRouteBuilder<void>(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (
              context,
              animation,
              secondaryAnimation,
              ) {
            return GameResultPage(
              gameInfo: widget.gameInfo,
              score: finalScore,
              bestScore: finalScore,
              success: false,
              reason: '게임 오버 / 최종 점수는 $finalScore점입니다.',
            );
          },
        ),
      );
    });
  }
  @override
  void dispose() {
    _game.gameOver.removeListener(_handleGameOver);

    _pageController.removeListener(_refreshPage);
    _pageController.dispose();

    _game.shutdown();
    unawaited(GameAudioService.instance.stopBgm());

    // 아래 3줄은 우선 제거
    // _game.score.dispose();
    // _game.nextLevel.dispose();
    // _game.gameOver.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E9CC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;

            final horizontalPadding = compact ? 10.0 : 20.0;

            // 득점 / 나의 최고 점수 / 미도리 고리 / 다음
            // 네 항목을 항상 한 줄에 표시합니다.
            const panelGap = 6.0;
            final usableInfoWidth =
                constraints.maxWidth -
                    (horizontalPadding + 4) * 2 -
                    panelGap * 3;

            final bubbleDiameter = compact
                ? (usableInfoWidth / 4).clamp(62.0, 82.0)
                : (usableInfoWidth / 4).clamp(78.0, 96.0);

            // 제목 높이/간격/원형 패널 높이를 모두 포함합니다.
            // 고정 높이보다 실제 콘텐츠가 커져 발생하는
            // RenderFlex overflow를 방지합니다.
            final infoAreaHeight = bubbleDiameter + 30.0;
            final headerHeight = compact ? 56.0 : 66.0;

            final availableGameHeight = math.max(
              0.0,
              constraints.maxHeight -
                  headerHeight -
                  infoAreaHeight,
            );

            final maxGameWidth =
                constraints.maxWidth - horizontalPadding * 2;

            final gameAspectRatio =
                MidoriPangpangGame.mobileViewAspectRatio;

            final widthFromHeight =
                availableGameHeight * gameAspectRatio;

            final gameWidth = math.min(
              maxGameWidth,
              widthFromHeight,
            );

            final gameHeight = gameWidth / gameAspectRatio;

            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: compact ? 56 : 66,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: '뒤로가기',
                              onPressed: () {
                                GameAudioService.instance.playSfx(
                                  GameSounds.buttonClick,
                                );

                                _game.shutdown();
                                unawaited(
                                  GameAudioService.instance.stopBgm(),
                                );

                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const Spacer(),
                            const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '미도리팡!',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFA500),
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF82400A),
                                      offset: Offset(-1.5, 0),
                                    ),
                                    Shadow(
                                      color: Color(0xFF82400A),
                                      offset: Offset(1.5, 0),
                                    ),
                                    Shadow(
                                      color: Color(0xFF82400A),
                                      offset: Offset(0, -1.5),
                                    ),
                                    Shadow(
                                      color: Color(0xFF82400A),
                                      offset: Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton.filled(
                              tooltip: '설정',
                              onPressed: () {
                                GameAudioService.instance.playSfx(
                                  GameSounds.buttonClick,
                                );
                                _game.pauseEngine();

                                unawaited(
                                  GameAudioSettingsDialog.show(context)
                                      .then((_) {
                                    if (mounted &&
                                        !_game.gameOver.value) {
                                      _game.resumeEngine();
                                    }
                                  }),
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFFFA8C4),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.settings),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: infoAreaHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding + 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _game.score,
                                  builder: (context, score, _) {
                                    return _BubblePanel(
                                      title: '득점',
                                      diameter: bubbleDiameter,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$score',
                                          style: TextStyle(
                                            fontSize:
                                            compact ? 22 : 25,
                                            fontWeight:
                                            FontWeight.w900,
                                            color: const Color(
                                              0xFFD27828,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: panelGap),

                            Expanded(
                              child: Center(
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _game.score,
                                  builder: (context, score, _) {
                                    final displayedBest =
                                    score > _myBestScore
                                        ? score
                                        : _myBestScore;

                                    return _BubblePanel(
                                      title: '나의 최고 점수',
                                      diameter: bubbleDiameter,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$displayedBest',
                                          style: TextStyle(
                                            fontSize:
                                            compact ? 20 : 23,
                                            fontWeight:
                                            FontWeight.w900,
                                            color: const Color(
                                              0xFFD27828,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: panelGap),

                            Expanded(
                              child: Center(
                                child: _BubblePanel(
                                  title: '미도리 고리',
                                  diameter: bubbleDiameter,
                                  child: Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder:
                                      const CircleBorder(),
                                      onTap: () {
                                        GameAudioService.instance
                                            .playSfx(
                                          GameSounds.buttonClick,
                                        );

                                        _game.pauseEngine();
                                        _pageController
                                            .showMemoryRing();
                                      },
                                      child: SizedBox.expand(
                                        child: Icon(
                                          Icons.account_tree,
                                          size: bubbleDiameter * 0.42,
                                          color: const Color(
                                            0xFFD29A24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: panelGap),

                            Expanded(
                              child: Center(
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _game.nextLevel,
                                  builder: (context, level, _) {
                                    return _BubblePanel(
                                      title: '다음',
                                      diameter: bubbleDiameter,
                                      child: _FruitPreview(
                                        level: level,
                                        diameter:
                                        bubbleDiameter * 0.54,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: gameWidth,
                          height: gameHeight,
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(12),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) {
                                if (gameWidth <= 0) {
                                  return;
                                }

                                _game.dropFruitAtRatio(
                                  details.localPosition.dx /
                                      gameWidth,
                                );
                              },
                              onHorizontalDragUpdate: (details) {
                                if (gameWidth <= 0) {
                                  return;
                                }

                                _game.updateAimFromRatio(
                                  details.localPosition.dx /
                                      gameWidth,
                                );
                              },
                              onHorizontalDragEnd: (_) {
                                _game.dropFruit();
                              },
                              child: GameWidget<MidoriPangpangGame>(
                                key: ValueKey(_game),
                                game: _game,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_pageController.isMemoryRingVisible)
                  Positioned.fill(
                    child: MemoryRingPanel(
                      onClose: () {
                        _pageController.hideMemoryRing();

                        if (!_game.gameOver.value) {
                          _game.resumeEngine();
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BubblePanel extends StatelessWidget {
  final String title;
  final Widget child;
  final double diameter;

  const _BubblePanel({
    required this.title,
    required this.child,
    this.diameter = 104,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: diameter + 8,
          height: 20,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
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
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.72),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB48855).withValues(alpha: 0.2),
                offset: const Offset(2, 4),
                blurRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _FruitPreview extends StatelessWidget {
  final int level;
  final double diameter;

  const _FruitPreview({required this.level, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Image.asset(
        GameImages.fruitAsset(level),
        width: diameter,
        height: diameter,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
            '다음 미도리 이미지 로드 실패: '
                '${GameImages.fruitAsset(level)}',
          );

          return const Icon(
            Icons.broken_image_outlined,
            color: Colors.red,
          );
        },
      ),
    );
  }
}
