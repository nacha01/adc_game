import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/game_data.dart';
import '../models/game_info.dart';
import '../services/network_service.dart';
import '../services/user_session.dart';

import 'game_intro_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({super.key});

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  final List<GameInfo> games = gameList;



  void goLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> goSignup() async {
    if (!await NetworkService.checkInternet(context)) {
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupPage(),
      ),
    );
  }

  void openGame(GameInfo game) {
    if (!UserSession.isLoggedIn) {
      goLogin();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameIntroPage(
          gameInfo: game,
        ),
      ),
    );
  }

  void logout() {
    UserSession.logout();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("로그아웃되었습니다."),
      ),
    );
  }

  void exitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          '게임 목록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE62D2D),
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: games.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return loginArea();
            }

            if (index == games.length + 1) {
              return waitingMessage();
            }

            final game = games[index - 1];

            return gameCard(context, game);
          },
        ),
      ),
    );
  }

  Widget loginArea() {
    if (UserSession.isLoggedIn) {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${UserSession.name}님 로그인 중",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE62D2D),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: logout,
              child: const Text("로그아웃"),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: goLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE62D2D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "로그인",
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: goSignup,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE62D2D),
                  side: const BorderSide(
                    color: Color(0xFFE62D2D),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "가입하기",
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: exitApp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF666666),
                  side: const BorderSide(
                    color: Color(0xFFBDBDBD),
                  ),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "나가기",
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget gameCard(BuildContext context, GameInfo game) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          openGame(game);
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE62D2D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '게임 개발자 : ${game.developer} - ${game.school}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                game.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE62D2D),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    openGame(game);
                  },
                  child: const Text(
                    '시작하기',
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

  Widget waitingMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          "★★★★★\n\n"
              "다음 게임의 주인공은\n"
              "바로 여러분입니다.\n\n"
              "여러분들의 게임 제작을\n"
              "기다립니다.\n\n"
              "★★★★★",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF777777),
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}