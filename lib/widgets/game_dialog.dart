import 'package:flutter/material.dart';

/// adc_game 플랫폼 공통 대화상자
///
/// 로그아웃/게임 종료/재시작/데이터 삭제 등
/// 사용자의 확인이 필요한 기능에 사용합니다.
class GameDialog {
  GameDialog._();

  /// 확인/취소 버튼이 있는 공통 대화상자를 표시합니다.
  ///
  /// 확인을 선택하면 true,
  /// 취소하거나 창을 닫으면 false를 반환합니다.
  static Future<bool> showConfirm(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = '확인',
        String cancelText = '취소',
        bool barrierDismissible = true,
        bool isDangerous = false,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(cancelText),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: isDangerous
                    ? const Color(0xFFB71C1C)
                    : const Color(0xFFE62D2D),
                foregroundColor: Colors.white,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// 확인 버튼만 있는 공통 안내창입니다.
  static Future<void> showMessage(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = '확인',
        bool barrierDismissible = true,
      }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE62D2D),
                foregroundColor: Colors.white,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}