import 'package:flutter/material.dart';

/// adc_game 플랫폼의 공통 정보 패널
///
/// 점수/최고 점수/남은 시간/단계처럼
/// 짧은 제목과 값을 표시하는 직사각형 패널에 사용합니다.
class GamePanel extends StatelessWidget {
  final String title;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color titleColor;
  final BorderRadiusGeometry borderRadius;

  const GamePanel({
    super.key,
    required this.title,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    this.backgroundColor = const Color(0xFFC81E1E),
    this.titleColor = Colors.white,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(12),
    ),
  });

  /// 문자열이나 숫자 값을 표시하는 기본 패널입니다.
  factory GamePanel.value({
    Key? key,
    required String title,
    required Object value,
    double? width,
    double? height,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    Color backgroundColor = const Color(0xFFC81E1E),
    Color titleColor = Colors.white,
    Color valueColor = Colors.white,
    double valueFontSize = 18,
    FontWeight valueFontWeight = FontWeight.bold,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(12),
    ),
  }) {
    return GamePanel(
      key: key,
      title: title,
      width: width,
      height: height,
      padding: padding,
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      borderRadius: borderRadius,
      child: Text(
        value.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: valueColor,
          fontSize: valueFontSize,
          fontWeight: valueFontWeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
