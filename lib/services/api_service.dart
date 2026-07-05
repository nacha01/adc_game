// api_service.dart
// mysqli 방식 PHP API와 통신하는 Flutter 파일입니다.
//
// pubspec.yaml에 아래 패키지를 추가하세요.
// dependencies:
//   http: ^1.2.2
//
// 추가 후 터미널에서 실행:
// flutter pub get

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 자신의 서버 주소로 수정하세요.
  // 예: https://example.com/game_api
  static const String baseUrl = "http://puhaha.pe.kr/dm_php_api";

  static Future<Map<String, dynamic>> getMyBestScore({
    required int userId,
    required String gameCode,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_my_best_score.php?user_id=$userId&game_code=$gameCode"),
    );

    return _decodeResponse(response);
  }


  static Future<Map<String, dynamic>> register({
    required String studentNumber,
    required String name,
    required String username,
    required String password,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register.php"),
      body: {
        "student_number": studentNumber,
        "name": name,
        "username": username,
        "password": password,
        "email": email,
      },
    );

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      body: {
        "username": username,
        "password": password,
      },
    );

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> saveScore({
    required int userId,
    required String gameCode,
    required int score,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/save_score.php"),
      body: {
        "user_id": userId.toString(),
        "game_code": gameCode,
        "score": score.toString(),
      },
    );

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> getRanking({
    required String gameCode,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/ranking.php?game_code=$gameCode"),
    );

    return _decodeResponse(response);
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        "success": false,
        "message": "서버 응답 형식이 올바르지 않습니다.",
        "raw": response.body,
      };
    } catch (e) {
      return {
        "success": false,
        "message": "JSON 해석 실패",
        "error": e.toString(),
        "raw": response.body,
      };
    }
  }
}
