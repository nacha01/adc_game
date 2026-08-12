import 'package:flutter/material.dart';

import '../games/game2048/game2048_page.dart';
import '../games/gameMidoriPangpang/gameMidoriPangpang_page.dart';
import '../models/game_info.dart';

class GameRegistry {
  GameRegistry._();

  /// 게임 ID에 맞는 실제 게임 화면을 생성합니다.
  ///
  /// 등록되지 않은 게임이면 null을 반환합니다.
  static Widget? createGame(GameInfo gameInfo) {
    switch (gameInfo.id) {
      case 'game_2048_sort':
        return Game2048Page(
          gameInfo: gameInfo,
        );

      case 'gameMidoriPangpang':
        return GameMidoriPangpang(
          gameInfo: gameInfo,
        );

      default:
        return null;
    }
  }

  /// 해당 게임이 플랫폼에 등록되어 있는지 확인합니다.
  static bool isRegistered(String gameId) {
    return supportedGameIds.contains(gameId);
  }

  /// 현재 실행 가능한 게임 ID 목록입니다.
  static const Set<String> supportedGameIds = {
    'game_2048_sort',
    'gameMidoriPangpang',
  };
}