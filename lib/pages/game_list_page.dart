import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/game_data.dart';
import '../models/game_info.dart';
import '../services/network_service.dart';
import '../services/user_session.dart';
import '../services/api_service.dart';
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

  Future<void> deleteAccount() async {
    if (!UserSession.isLoggedIn || UserSession.username == null) {
      return;
    }

    final passwordController = TextEditingController();

    // 1단계: 비밀번호 입력
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("회원 탈퇴"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "회원 탈퇴 시 회원 정보와 모든 게임 기록이 삭제됩니다.\n"
                    "삭제된 정보는 복구할 수 없습니다.",
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "비밀번호 확인",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text("비밀번호를 입력하세요."),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("탈퇴하기"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      passwordController.dispose();
      return;
    }

    final password = passwordController.text;
    passwordController.dispose();

    if (!mounted) return;

    // 2단계: 최종 확인
    final bool? finalConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("정말 탈퇴하시겠습니까?"),
          content: const Text(
            "회원 정보와 모든 게임 기록이 영구적으로 삭제됩니다.\n"
                "삭제된 정보는 복구할 수 없습니다.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("최종 탈퇴"),
            ),
          ],
        );
      },
    );

    if (finalConfirmed != true) {
      return;
    }

    // 인터넷 연결 확인
    if (!await NetworkService.checkInternet(context)) {
      return;
    }

    if (!mounted) return;

    // 서버에 회원 탈퇴 요청
    try {
      final result = await ApiService.deleteAccount(
        username: UserSession.username!,
        password: password,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        UserSession.logout();

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ?? "회원 탈퇴가 완료되었습니다.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"] ?? "회원 탈퇴에 실패했습니다.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("회원 탈퇴 처리 중 오류가 발생했습니다."),
        ),
      );
    }
  }

  void exitApp() {
    SystemNavigator.pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

        appBar: AppBar(
          toolbarHeight: 105,
          titleSpacing: 12,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 아이콘 + 앱 제목
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    '만놀터',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              // 제목의 의미
              const Center(
                child: Text(
                  '디문고에서 만들고 놀다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // 학교 / 학과
              const SizedBox(
                width: double.infinity,
                child: Text(
                  '안산디자인문화고등학교 / 미디어콘텐츠과',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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

            if (index >= 1 && index <= games.length) {
              final game = games[index - 1];
              return gameCard(context, game);
            }



            return waitingMessage();
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

            // 로그아웃
            OutlinedButton(
              onPressed: logout,
              child: const Text("로그아웃"),
            ),

            const SizedBox(width: 8),

            // 회원 탈퇴
            OutlinedButton(
              onPressed: deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("회원탈퇴"),
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
          "★★★★★\n"
              "다음 게임의 주인공은 바로 여러분입니다.\n"
              "여러분들의 게임 제작을 기다립니다.\n"
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