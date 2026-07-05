import 'package:flutter/material.dart';

class GameRulePage extends StatelessWidget {
  const GameRulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('게임 규칙'),
          centerTitle: true,
          backgroundColor: const Color(0xFFE62D2D),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flag), text: '목표'),
              Tab(icon: Icon(Icons.sports_esports), text: '방법'),
              Tab(icon: Icon(Icons.school), text: '학습'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_GoalTab(), _HowToPlayTab(), _LearningTab()],
        ),
      ),
    );
  }
}

class _GoalTab extends StatelessWidget {
  const _GoalTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      Text('🎯 게임 목표',style: TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      SizedBox(height:16),
      Text('• 2048 블록을 만들어 높은 점수를 획득합니다.'),
      Text('• 게임 종료 후 점수는 자동 저장됩니다.'),
      Text('• 로그인한 경우 순위에 반영됩니다.'),
      SizedBox(height:16),
      Text('게임 종료 조건'),
      Text('• 제한시간 종료'),
      Text('• 이동 불가'),
      Text('• 게임 종료 버튼'),
    ],
  );
}

class _HowToPlayTab extends StatelessWidget {
  const _HowToPlayTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      Text('🎮 게임 방법',style: TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      SizedBox(height:16),
      Text('① 화면을 상하좌우로 스와이프합니다.'),
      Text('② 같은 숫자는 합쳐집니다.'),
      Text('③ 원하는 행을 터치하여 선택합니다.'),
      Text('④ 행 정렬 버튼으로 선택한 행을 오름차순 정렬합니다.'),
      Text('⑤ 전략적으로 높은 점수를 획득하세요.'),
    ],
  );
}

class _LearningTab extends StatelessWidget {
  const _LearningTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      Text('📚 학습 목표',style: TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      SizedBox(height:16),
      Text('이 게임은 선택정렬(Selection Sort)을 체험하는 교육용 게임입니다.'),
      Text('• 자료구조 이해'),
      Text('• 선택정렬 원리 학습'),
      Text('• 전략적 사고력 향상'),
      Text('• 데이터 배치의 중요성 이해'),
    ],
  );
}
