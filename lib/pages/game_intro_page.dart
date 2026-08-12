import 'dart:async';

import 'package:flutter/material.dart';

import '../managers/game_manager.dart';
import '../models/game_info.dart';
import '../widgets/game_action_button.dart';
import 'game_list_page.dart';
import 'game_rule_page.dart';
import 'ranking_page.dart';

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
                  '게임 개발자 : ${gameInfo.developer}',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  gameInfo.school,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
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
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                GameActionButton(
                  text: '게임 시작',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    unawaited(
                      GameManager.instance.launchGame(
                        context,
                        gameInfo,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                GameActionButton(
                  text: '게임 방법 소개',
                  icon: Icons.menu_book,
                  style: GameActionButtonStyle.outlined,
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => GameRulePage(
                          gameInfo: gameInfo,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                GameActionButton(
                  text: '순위 보기',
                  icon: Icons.emoji_events,
                  style: GameActionButtonStyle.outlined,
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => RankingPage(
                          gameInfo: gameInfo,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                GameActionButton(
                  text: '홈으로',
                  icon: Icons.home,
                  style: GameActionButtonStyle.outlined,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const GameListPage(),
                      ),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}