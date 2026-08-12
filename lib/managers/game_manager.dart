import 'package:flutter/material.dart';

import '../data/game_registry.dart';
import '../models/game_info.dart';

/// adc_game 플랫폼의 게임 실행 관리자
///
/// 역할:
/// - 게임 등록 여부 확인
/// - GameRegistry를 통한 게임 화면 생성
/// - 게임 실행
/// - 게임 다시 시작
/// - 등록되지 않은 게임 안내
class GameManager {
  GameManager._();

  static final GameManager instance = GameManager._();

  /// 해당 게임이 플랫폼에 등록되어 있는지 확인합니다.
  bool isRegistered(GameInfo gameInfo) {
    return GameRegistry.isRegistered(gameInfo.id);
  }

  /// 등록된 게임을 새 화면으로 실행합니다.
  ///
  /// 게임 소개 화면에서 처음 게임을 시작할 때 사용합니다.
  Future<bool> launchGame(
      BuildContext context,
      GameInfo gameInfo,
      ) async {
    final gamePage = GameRegistry.createGame(gameInfo);

    if (gamePage == null) {
      _showUnavailableMessage(context);
      return false;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => gamePage,
      ),
    );

    return true;
  }

  /// 현재 화면을 제거하고 같은 게임을 다시 시작합니다.
  ///
  /// 게임 결과 화면에서 '다시 하기'를 눌렀을 때 사용합니다.
  Future<bool> restartGame(
      BuildContext context,
      GameInfo gameInfo,
      ) async {
    final gamePage = GameRegistry.createGame(gameInfo);

    if (gamePage == null) {
      _showUnavailableMessage(context);
      return false;
    }

    await Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => gamePage,
      ),
    );

    return true;
  }

  /// 등록되지 않은 게임 안내
  void _showUnavailableMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('아직 준비되지 않은 게임입니다.'),
      ),
    );
  }
}