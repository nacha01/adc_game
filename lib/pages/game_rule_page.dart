import 'package:flutter/material.dart';

import '../models/game_info.dart';

class GameRulePage extends StatelessWidget {
  final GameInfo gameInfo;

  const GameRulePage({
    super.key,
    required this.gameInfo,
  });

  static const Color _mainColor = Color(0xFFE62D2D);

  @override
  Widget build(BuildContext context) {
    final guide = _guideFor(gameInfo);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          '게임 안내',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _mainColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GuideTitle(
                    title: gameInfo.title,
                    subtitle: guide.subtitle,
                  ),
                  const SizedBox(height: 24),

                  _GuideSection(
                    icon: Icons.flag_rounded,
                    title: '게임 목표',
                    children: guide.goals,
                  ),

                  if (guide.endConditions.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _SubSection(
                      title: '게임 종료 조건',
                      children: guide.endConditions,
                    ),
                  ],

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 28),

                  _GuideSection(
                    icon: Icons.sports_esports_rounded,
                    title: '게임 방법',
                    numbered: true,
                    children: guide.howToPlay,
                  ),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 28),

                  _GuideSection(
                    icon: Icons.school_rounded,
                    title: '학습 내용',
                    intro: guide.learningIntro,
                    children: guide.learningPoints,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _GameGuide _guideFor(GameInfo gameInfo) {
    switch (gameInfo.id) {
      case 'game_2048_sort':
        return const _GameGuide(
          subtitle: '2048 게임과 선택정렬 기능을 함께 활용하는 게임입니다.',
          goals: [
            '2048 블록을 만들어 높은 점수를 획득합니다.',
            '선택한 행을 정렬하여 블록의 배치를 전략적으로 바꿉니다.',
            '게임 종료 후 로그인한 사용자의 점수는 순위에 반영됩니다.',
          ],
          endConditions: [
            '제한시간 종료',
            '더 이상 이동할 수 없는 경우',
            '게임 종료 버튼을 누른 경우',
          ],
          howToPlay: [
            '화면을 상하좌우로 스와이프하여 블록을 이동합니다.',
            '같은 숫자의 블록이 만나면 하나로 합쳐집니다.',
            '정렬할 행을 터치하여 선택합니다.',
            '행 정렬 버튼을 눌러 선택한 행을 오름차순으로 정렬합니다.',
            '이동과 정렬을 전략적으로 사용하여 높은 점수에 도전합니다.',
          ],
          learningIntro:
          '2048 게임에 선택정렬 개념을 적용하여 자료의 이동과 정렬 과정을 체험합니다.',
          learningPoints: [
            '자료구조에서 데이터의 배치와 이동 이해',
            '선택정렬의 원리와 활용 방법 이해',
            '정렬 결과에 따른 데이터 배치 변화 관찰',
            '문제 해결을 위한 전략적 사고력 향상',
          ],
        );

      case 'gameMidoriPangpang':
        return const _GameGuide(
          subtitle: '같은 과일을 합쳐 더 큰 과일로 진화시키는 물리 게임입니다.',
          goals: [
            '같은 과일 두 개를 합쳐 다음 단계의 과일로 진화시킵니다.',
            '과일을 효율적으로 배치하여 높은 점수를 획득합니다.',
            '로그인한 사용자의 최고 점수는 순위에 반영됩니다.',
          ],
          endConditions: [
            '쌓인 과일이 상단 제한선을 일정 시간 넘은 경우',
          ],
          howToPlay: [
            '화면에서 과일을 떨어뜨릴 위치를 정합니다.',
            '화면을 터치하여 현재 과일을 바구니 안으로 떨어뜨립니다.',
            '같은 종류의 과일 두 개가 닿으면 다음 단계의 과일로 합쳐집니다.',
            '다음 항목에서 다음에 나올 과일을 확인합니다.',
            '미도리 고리를 눌러 과일의 진화 순서를 확인합니다.',
            '과일이 위쪽 제한선을 넘지 않도록 배치하며 높은 점수에 도전합니다.',
          ],
          learningIntro:
          '과일의 충돌과 병합 과정을 통해 단계적 진화 구조와 물리 기반 상호작용을 체험합니다.',
          learningPoints: [
            '같은 데이터가 결합되어 다음 단계로 변화하는 구조 이해',
            '과일 진화 순서를 통한 단계적 자료 관계 이해',
            '충돌과 위치에 따른 결과 변화를 관찰하며 문제 해결',
            '공간 배치와 다음 과일을 고려한 전략적 사고',
          ],
        );

      default:
        return _GameGuide(
          subtitle: gameInfo.description,
          goals: const [
            '게임의 목표를 확인하고 높은 점수에 도전합니다.',
          ],
          endConditions: const [],
          howToPlay: const [
            '게임 화면의 안내에 따라 조작합니다.',
          ],
          learningIntro: '게임 활동을 통해 문제 해결 과정을 체험합니다.',
          learningPoints: const [
            '게임의 규칙과 데이터 처리 과정을 이해합니다.',
          ],
        );
    }
  }
}

class _GameGuide {
  final String subtitle;
  final List<String> goals;
  final List<String> endConditions;
  final List<String> howToPlay;
  final String learningIntro;
  final List<String> learningPoints;

  const _GameGuide({
    required this.subtitle,
    required this.goals,
    required this.endConditions,
    required this.howToPlay,
    required this.learningIntro,
    required this.learningPoints,
  });
}

class _GuideTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _GuideTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title 게임 안내',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE62D2D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF666666),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? intro;
  final List<String> children;
  final bool numbered;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.children,
    this.intro,
    this.numbered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFE62D2D),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
        if (intro != null) ...[
          const SizedBox(height: 16),
          Text(
            intro!,
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: Color(0xFF444444),
            ),
          ),
        ],
        const SizedBox(height: 14),
        ...List.generate(
          children.length,
              (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: numbered ? 30 : 22,
                  child: Text(
                    numbered ? '${index + 1}.' : '•',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE62D2D),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    children[index],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SubSection extends StatelessWidget {
  final String title;
  final List<String> children;

  const _SubSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE62D2D),
            ),
          ),
          const SizedBox(height: 10),
          ...children.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Color(0xFF444444),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
