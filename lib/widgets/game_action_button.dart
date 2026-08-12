import 'package:flutter/material.dart';

/// adc_game 플랫폼의 공통 버튼
///
/// 게임 시작/게임 방법/순위/홈/다시하기 등
/// 플랫폼 전체에서 동일한 크기와 디자인을 사용할 때 활용합니다.
class GameActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final GameActionButtonStyle style;
  final double width;
  final double height;

  const GameActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.style = GameActionButtonStyle.primary,
    this.width = 230,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: switch (style) {
        GameActionButtonStyle.primary => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE62D2D),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        ),
        GameActionButtonStyle.outlined => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE62D2D),
            side: const BorderSide(
              color: Color(0xFFE62D2D),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        ),
        GameActionButtonStyle.lightOutlined => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: Colors.white,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        ),

        GameActionButtonStyle.danger => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        ),
      },
    );
  }
}

enum GameActionButtonStyle {
  primary,
  outlined,
  lightOutlined,
  danger,
}