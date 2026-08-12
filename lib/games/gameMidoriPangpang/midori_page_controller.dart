import 'package:flutter/foundation.dart';

/// 미도리팡팡 Flutter 화면의 UI 상태를 관리합니다.
class MidoriPageController extends ChangeNotifier {
  bool _isMemoryRingVisible = false;
  bool _resultNavigationStarted = false;

  bool get isMemoryRingVisible => _isMemoryRingVisible;
  bool get resultNavigationStarted => _resultNavigationStarted;

  void showMemoryRing() {
    if (_isMemoryRingVisible) {
      return;
    }

    _isMemoryRingVisible = true;
    notifyListeners();
  }

  void hideMemoryRing() {
    if (!_isMemoryRingVisible) {
      return;
    }

    _isMemoryRingVisible = false;
    notifyListeners();
  }

  bool beginResultNavigation() {
    if (_resultNavigationStarted) {
      return false;
    }

    _resultNavigationStarted = true;
    return true;
  }

  void resetForNewGame() {
    _isMemoryRingVisible = false;
    _resultNavigationStarted = false;
    notifyListeners();
  }
}
