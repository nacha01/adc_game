import 'dart:io';

import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../services/api_service.dart';
import '../services/user_session.dart';
import '../services/message_service.dart';
import 'game_list_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkService.checkInternet(context);
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!await NetworkService.checkInternet(context)) {
      return;
    }
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      MessageService.error(
        context,
        "아이디와 비밀번호를 입력하세요.",
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      if (result["success"] == true) {
        final user = result["user"];

        UserSession.login(
          id: int.parse(user["id"].toString()),
          studentNumberValue: user["student_number"].toString(),
          nameValue: user["name"].toString(),
          usernameValue: user["username"].toString(),
          emailValue: user["email"].toString(),
        );

        MessageService.success(
          context,
          "로그인되었습니다.",
        );

        await Future.delayed(
          const Duration(milliseconds: 700),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const GameListPage(),
          ),
        );
      } else {
        MessageService.error(
          context,
          result["message"] ?? "아이디 또는 비밀번호가 올바르지 않습니다.",
        );
      }
    } on SocketException {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      MessageService.warning(
        context,
        "인터넷에 연결되어 있지 않습니다.",
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      MessageService.warning(
        context,
        "서버에 연결할 수 없습니다.\n잠시 후 다시 시도하세요.",
      );
    }
  }

  void goWithoutLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const GameListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "게임 로그인",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE62D2D),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "로그인하면 점수가 저장되고 순위에 반영됩니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF444444),
                  ),
                ),

                const SizedBox(height: 34),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "아이디",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "비밀번호",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE62D2D),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      loading ? "로그인 중..." : "로그인",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: loading
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text("가입하기"),
                  ),
                ),

                const SizedBox(height: 10),


              ],
            ),
          ),
        ),
      ),
    );
  }
}