import 'package:flutter/material.dart';
import 'game_list_page.dart';
import 'ranking_page.dart';
import '../games/game2048/game2048_page.dart';
import '../models/game_info.dart';
import 'game_rule_page.dart';

class GameIntroPage extends StatelessWidget {
  final GameInfo gameInfo;

  const GameIntroPage({
    super.key,
    required this.gameInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameInfo.title),
        centerTitle: true,
        backgroundColor: const Color(0xFFE62D2D),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Text(
                  gameInfo.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "게임 개발자 : ${gameInfo.developer}",
                  style: const TextStyle(fontSize: 18),
                ),

                Text(
                  gameInfo.school,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gameInfo.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 35),

                // 게임 시작
                SizedBox(
                  width: 230,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      "게임 시작",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Game2048Page(
                            gameInfo: gameInfo,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // ★ 새로 추가되는 버튼
                SizedBox(
                  width: 230,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text(
                      "게임 방법 소개",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameRulePage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // 순위 보기
                SizedBox(
                  width: 230,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.emoji_events),
                    label: const Text(
                      "순위 보기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RankingPage(
                            gameInfo: gameInfo,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // 홈으로
                SizedBox(
                  width: 230,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.emoji_events),
                    label: const Text(
                      "홈으로",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameListPage(),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}