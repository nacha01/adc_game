import 'package:flutter/material.dart';

import 'pages/game_list_page.dart';
import 'services/game_audio_service.dart';

// 기존 main()을 다음처럼 비동기로 변경
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GameAudioService.instance.initializeSettings();

  runApp(const MyApp()); // 현재 프로젝트의 실제 앱 클래스명을 유지하세요.
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