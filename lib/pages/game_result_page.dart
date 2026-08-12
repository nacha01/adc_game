import 'dart:async';

import 'package:flutter/material.dart';

import '../managers/game_manager.dart';
import '../models/game_info.dart';
import '../services/ranking_service.dart';
import '../services/user_session.dart';
import '../widgets/game_action_button.dart';
import 'game_intro_page.dart';
import 'ranking_page.dart';

class GameResultPage extends StatefulWidget {
  final GameInfo gameInfo;
  final int score;
  final int bestScore;
  final bool success;
  final String reason;

  const GameResultPage({
    super.key,
    required this.gameInfo,
    required this.score,
    required this.bestScore,
    required this.success,
    required this.reason,
  });

  @override
  State<GameResultPage> createState() => _GameResultPageState();
}

class _GameResultPageState extends State<GameResultPage> {
  bool _isSaving = false;
  bool _scoreSaved = false;
  late int _bestScore;
  String _saveMessage = '로그인하지 않은 경우 점수는 저장되지 않습니다.';

  @override
  void initState() {
    super.initState();
    _bestScore = widget.bestScore > widget.score
        ? widget.bestScore
        : widget.score;
    unawaited(_saveScoreIfLoggedIn());
  }
  Future<void> _saveScoreIfLoggedIn() async {
    final userId = UserSession.userId;

    if (!UserSession.isLoggedIn || userId == null) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveMessage = '점수를 저장하는 중입니다.';
    });

    final saveResult = await RankingService.instance.saveScore(
      userId: userId,
      gameCode: widget.gameInfo.id,
      score: widget.score,
    );

    if (!mounted) {
      return;
    }

    if (!saveResult.success) {
      setState(() {
        _isSaving = false;
        _scoreSaved = false;
        _saveMessage = saveResult.message;
      });

      return;
    }

    final bestScoreResult =
    await RankingService.instance.getMyBestScore(
      userId: userId,
      gameCode: widget.gameInfo.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _scoreSaved = true;
      _saveMessage = saveResult.message;

      if (bestScoreResult.success) {
        _bestScore = bestScoreResult.score;
      } else if (widget.score > _bestScore) {
        _bestScore = widget.score;
      }
    });
  }



  Future<void> _restartGame() async {
    await GameManager.instance.restartGame(
      context,
      widget.gameInfo,
    );
  }

  void _goToGameIntro() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => GameIntroPage(
          gameInfo: widget.gameInfo,
        ),
      ),
          (route) => false,
    );
  }

  void _openRanking() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RankingPage(
          gameInfo: widget.gameInfo,
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil(
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE62D2D),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.success ? '성공!' : '게임 종료',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.gameInfo.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '게임 개발자 : '
                        '${widget.gameInfo.developer} - '
                        '${widget.gameInfo.school}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _resultBox(
                    '종료 이유',
                    widget.reason,
                  ),
                  _resultBox(
                    '최종 점수',
                    '${widget.score}점',
                  ),
                  _resultBox(
                    '최고 점수',
                    '$_bestScore점',
                  ),
                  _resultBox(
                    '점수 저장',
                    _saveMessage,
                    showLoading: _isSaving,
                    success: _scoreSaved,
                  ),
                  const SizedBox(height: 24),
                  GameActionButton(
                    text: '다시 하기',
                    icon: Icons.restart_alt,
                    width: 220,
                    height: 48,
                    onPressed: () {
                      unawaited(_restartGame());
                    },
                  ),
                  const SizedBox(height: 10),
                  GameActionButton(
                    text: '게임 소개로',
                    icon: Icons.info_outline,
                    style: GameActionButtonStyle.lightOutlined,
                    width: 220,
                    height: 48,
                    onPressed: _goToGameIntro,
                  ),
                  const SizedBox(height: 10),
                  GameActionButton(
                    text: '순위 보기',
                    icon: Icons.emoji_events,
                    style: GameActionButtonStyle.lightOutlined,
                    width: 220,
                    height: 48,
                    onPressed: _openRanking,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 220,
                    height: 1,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  GameActionButton(
                    text: '홈으로',
                    icon: Icons.home_rounded,
                    style: GameActionButtonStyle.lightOutlined,
                    width: 220,
                    height: 48,
                    onPressed: _goHome,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultBox(
      String title,
      String value, {
        bool showLoading = false,
        bool success = false,
      }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFC81E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          if (showLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (success) ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}