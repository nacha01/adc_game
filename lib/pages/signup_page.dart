import 'dart:io';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/message_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final studentNumberController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    studentNumberController.dispose();
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final studentNumber = studentNumberController.text.trim();
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final email = emailController.text.trim();

    if (studentNumber.isEmpty ||
        name.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        email.isEmpty) {
      MessageService.error(
        context,
        "모든 항목을 입력하세요.",
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.register(
        studentNumber: studentNumber,
        name: name,
        username: username,
        password: password,
        email: email,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      if (result["success"] == true) {
        MessageService.success(
          context,
          "회원가입이 완료되었습니다. 로그인하세요.",
        );

        await Future.delayed(
          const Duration(milliseconds: 800),
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        MessageService.error(
          context,
          result["message"] ?? "회원가입에 실패했습니다.",
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

  Widget inputField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("회원가입"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE62D2D),
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              inputField(
                controller: studentNumberController,
                label: "학번",
                keyboardType: TextInputType.number,
              ),

              inputField(
                controller: nameController,
                label: "이름",
              ),

              inputField(
                controller: usernameController,
                label: "아이디",
              ),

              inputField(
                controller: passwordController,
                label: "비밀번호",
                obscureText: true,
              ),

              inputField(
                controller: emailController,
                label: "이메일",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE62D2D),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    loading ? "가입 중..." : "가입하기",
                    style: const TextStyle(
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
}