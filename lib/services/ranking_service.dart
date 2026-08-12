import 'package:flutter/foundation.dart';

import 'api_service.dart';

/// adc_game 플랫폼의 공통 랭킹 서비스
///
/// 역할:
/// - 게임별 점수 저장
/// - 게임별 랭킹 조회
/// - 사용자 최고 점수 조회
/// - API 오류 형식 통일
class RankingService {
  RankingService._();

  static final RankingService instance = RankingService._();

  /// 사용자의 점수를 서버에 저장합니다.
  Future<RankingResult> saveScore({
    required int userId,
    required String gameCode,
    required int score,
  }) async {
    if (userId <= 0) {
      return const RankingResult.failure(
        message: '사용자 정보가 올바르지 않습니다.',
      );
    }

    if (gameCode.trim().isEmpty) {
      return const RankingResult.failure(
        message: '게임 코드가 올바르지 않습니다.',
      );
    }

    if (score < 0) {
      return const RankingResult.failure(
        message: '점수는 0점 이상이어야 합니다.',
      );
    }

    try {
      final response = await ApiService.saveScore(
        userId: userId,
        gameCode: gameCode,
        score: score,
      );

      if (response['success'] == true) {
        return RankingResult.success(
          message: response['message']?.toString() ?? '점수가 저장되었습니다.',
          data: response,
        );
      }

      return RankingResult.failure(
        message: response['message']?.toString() ?? '점수를 저장하지 못했습니다.',
        data: response,
      );
    } catch (e, stackTrace) {
      debugPrint('점수 저장 실패: $e');
      debugPrintStack(stackTrace: stackTrace);

      return RankingResult.failure(
        message: '서버에 점수를 저장하지 못했습니다.',
        error: e,
      );
    }
  }

  /// 게임별 랭킹을 불러옵니다.
  Future<RankingListResult> getRanking({
    required String gameCode,
  }) async {
    if (gameCode.trim().isEmpty) {
      return const RankingListResult.failure(
        message: '게임 코드가 올바르지 않습니다.',
      );
    }

    try {
      final response = await ApiService.getRanking(
        gameCode: gameCode,
      );

      if (response['success'] != true) {
        return RankingListResult.failure(
          message: response['message']?.toString() ?? '순위를 불러오지 못했습니다.',
        );
      }

      final rawRanking = response['ranking'];

      if (rawRanking is! List) {
        return const RankingListResult.failure(
          message: '순위 데이터 형식이 올바르지 않습니다.',
        );
      }

      final entries = rawRanking
          .whereType<Map>()
          .map(
            (item) => RankingEntry.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      return RankingListResult.success(
        entries: entries,
      );
    } catch (e, stackTrace) {
      debugPrint('랭킹 조회 실패: $e');
      debugPrintStack(stackTrace: stackTrace);

      return RankingListResult.failure(
        message: '서버에서 순위를 불러오지 못했습니다.',
        error: e,
      );
    }
  }

  /// 사용자의 게임별 최고 점수를 불러옵니다.
  Future<BestScoreResult> getMyBestScore({
    required int userId,
    required String gameCode,
  }) async {
    try {
      final response = await ApiService.getMyBestScore(
        userId: userId,
        gameCode: gameCode,
      );

      if (response['success'] != true) {
        return BestScoreResult.failure(
          message: response['message']?.toString() ?? '최고 점수를 불러오지 못했습니다.',
        );
      }

      final rawScore = response['best_score'];
      final score = int.tryParse(rawScore?.toString() ?? '') ?? 0;

      return BestScoreResult.success(
        score: score,
      );
    } catch (e, stackTrace) {
      debugPrint('최고 점수 조회 실패: $e');
      debugPrintStack(stackTrace: stackTrace);

      return BestScoreResult.failure(
        message: '서버에서 최고 점수를 불러오지 못했습니다.',
        error: e,
      );
    }
  }
}

/// 순위 한 줄의 데이터 모델
class RankingEntry {
  final String name;
  final int bestScore;

  const RankingEntry({
    required this.name,
    required this.bestScore,
  });

  factory RankingEntry.fromMap(Map<String, dynamic> map) {
    return RankingEntry(
      name: map['name']?.toString() ?? '이름 없음',
      bestScore: int.tryParse(
        map['best_score']?.toString() ?? '',
      ) ??
          0,
    );
  }
}

/// 점수 저장 결과
class RankingResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final Object? error;

  const RankingResult._({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  const RankingResult.success({
    required String message,
    Map<String, dynamic>? data,
  }) : this._(
    success: true,
    message: message,
    data: data,
  );

  const RankingResult.failure({
    required String message,
    Map<String, dynamic>? data,
    Object? error,
  }) : this._(
    success: false,
    message: message,
    data: data,
    error: error,
  );
}

/// 랭킹 목록 조회 결과
class RankingListResult {
  final bool success;
  final String message;
  final List<RankingEntry> entries;
  final Object? error;

  const RankingListResult._({
    required this.success,
    required this.message,
    required this.entries,
    this.error,
  });

  const RankingListResult.success({
    required List<RankingEntry> entries,
  }) : this._(
    success: true,
    message: '',
    entries: entries,
  );

  const RankingListResult.failure({
    required String message,
    Object? error,
  }) : this._(
    success: false,
    message: message,
    entries: const [],
    error: error,
  );
}

/// 사용자 최고 점수 조회 결과
class BestScoreResult {
  final bool success;
  final String message;
  final int score;
  final Object? error;

  const BestScoreResult._({
    required this.success,
    required this.message,
    required this.score,
    this.error,
  });

  const BestScoreResult.success({
    required int score,
  }) : this._(
    success: true,
    message: '',
    score: score,
  );

  const BestScoreResult.failure({
    required String message,
    Object? error,
  }) : this._(
    success: false,
    message: message,
    score: 0,
    error: error,
  );
}