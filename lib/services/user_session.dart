// user_session.dart
// 로그인한 사용자 정보를 앱 실행 중 임시로 보관합니다.

class UserSession {
  static int? userId;
  static String? studentNumber;
  static String? name;
  static String? username;
  static String? email;

  static bool get isLoggedIn => userId != null;

  static void login({
    required int id,
    required String studentNumberValue,
    required String nameValue,
    required String usernameValue,
    required String emailValue,
  }) {
    userId = id;
    studentNumber = studentNumberValue;
    name = nameValue;
    username = usernameValue;
    email = emailValue;
  }

  static void logout() {
    userId = null;
    studentNumber = null;
    name = null;
    username = null;
    email = null;
  }
}
