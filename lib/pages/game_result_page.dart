import 'package:flutter/material.dart';

import '../models/game_info.dart';
import '../games/game2048/game2048_page.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
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
  bool scoreSaved = false;
  String saveMessage = "로그인하지 않은 경우 점수는 저장되지 않습니다.";

  @override
  void initState() {
    super.initState();
    saveScoreIfLoggedIn();
  }

  Future<void> saveScoreIfLoggedIn() async {
    if (!UserSession.isLoggedIn) {
      return;
    }

    final result = await ApiService.saveScore(
      userId: UserSession.userId!,
      gameCode: widget.gameInfo.id,
      score: widget.score,
    );

    setState(() {
      scoreSaved = result["success"] == true;
      saveMessage = result["message"] ?? "점수 저장 결과를 확인할 수 없습니다.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '게임 개발자 : ${widget.gameInfo.developer} - ${widget.gameInfo.school}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                resultBox('종료 이유', widget.reason),
                resultBox('최종 점수', '${widget.score}점'),
                resultBox(
                  '최고 점수',
                  '${widget.bestScore > widget.score ? widget.bestScore : widget.score}점',
                ),
                resultBox('점수 저장', saveMessage),

                const SizedBox(height: 24),

                SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Game2048Page(
                            gameInfo: widget.gameInfo,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      '다시 하기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameIntroPage(
                            gameInfo: widget.gameInfo,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      '게임 소개로',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 220,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RankingPage(
                            gameInfo: widget.gameInfo,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text(
                      '순위 보기',
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
      ),
    );
  }

  Widget resultBox(String title, String value) {
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

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
