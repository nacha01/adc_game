import 'package:flutter/material.dart';

import 'pages/game_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '자료구조 게임',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFE62D2D),
        useMaterial3: true,
      ),
      home: const GameListPage(),
    );
  }
}