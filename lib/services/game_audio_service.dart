import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'save_service.dart';

class GameAudioService {
  GameAudioService._();

  static final GameAudioService instance = GameAudioService._();

  bool _isInitialized = false;
  bool _settingsLoaded = false;

  bool _bgmEnabled = true;
  bool _sfxEnabled = true;

  double _bgmVolume = 0.4;
  double _sfxVolume = 1.0;

  String? _currentBgm;

  bool get isInitialized => _isInitialized;
  bool get settingsLoaded => _settingsLoaded;
  bool get bgmEnabled => _bgmEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  String? get currentBgm => _currentBgm;

  Future<void> initializeSettings() async {
    if (_settingsLoaded) {
      return;
    }

    try {
      final settings = await SaveService.instance.loadAudioSettings();

      _bgmEnabled = settings.bgmEnabled;
      _sfxEnabled = settings.sfxEnabled;
      _bgmVolume = settings.bgmVolume;
      _sfxVolume = settings.sfxVolume;
      _settingsLoaded = true;

      debugPrint(
        '오디오 설정 로드 완료: '
            'BGM=$_bgmEnabled/${(_bgmVolume * 100).round()}%, '
            'SFX=$_sfxEnabled/${(_sfxVolume * 100).round()}%',
      );
    } catch (e, stackTrace) {
      debugPrint('오디오 설정 로드 실패: $e');
      debugPrintStack(stackTrace: stackTrace);
      _settingsLoaded = true;
    }
  }

  Future<void> initialize(List<String> audioFiles) async {
    await initializeSettings();

    if (_isInitialized) {
      return;
    }

    try {
      await FlameAudio.audioCache.loadAll(audioFiles);
      _isInitialized = true;
      debugPrint('GameAudioService 초기화 완료: ${audioFiles.length}개');
    } catch (e, stackTrace) {
      debugPrint('GameAudioService 초기화 실패: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> playBgm(
      String fileName, {
        double? volume,
      }) async {
    await initializeSettings();

    _currentBgm = fileName;

    if (!_bgmEnabled) {
      return;
    }

    final appliedVolume = _normalizeVolume(volume ?? _bgmVolume);

    try {
      await FlameAudio.bgm.play(
        fileName,
        volume: appliedVolume,
      );
    } catch (e, stackTrace) {
      debugPrint('BGM 재생 실패: $fileName / $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> stopBgm({
    bool clearCurrentBgm = true,
  }) async {
    try {
      await FlameAudio.bgm.stop();
    } catch (e, stackTrace) {
      debugPrint('BGM 정지 실패: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (clearCurrentBgm) {
        _currentBgm = null;
      }
    }
  }

  Future<void> pauseBgm() async {
    if (!_bgmEnabled) {
      return;
    }

    try {
      await FlameAudio.bgm.pause();
    } catch (e, stackTrace) {
      debugPrint('BGM 일시정지 실패: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> resumeBgm() async {
    if (!_bgmEnabled || _currentBgm == null) {
      return;
    }

    try {
      await FlameAudio.bgm.resume();
    } catch (e, stackTrace) {
      debugPrint('BGM 재개 실패: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void playSfx(
      String fileName, {
        double? volume,
      }) {
    if (!_sfxEnabled) {
      return;
    }

    final appliedVolume = _normalizeVolume(volume ?? _sfxVolume);

    unawaited(
      _playSfxInternal(
        fileName,
        volume: appliedVolume,
      ),
    );
  }

  Future<void> _playSfxInternal(
      String fileName, {
        required double volume,
      }) async {
    try {
      await FlameAudio.play(
        fileName,
        volume: volume,
      );
    } catch (e, stackTrace) {
      debugPrint('효과음 재생 실패: $fileName / $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> setBgmEnabled(bool enabled) async {
    if (_bgmEnabled == enabled) {
      return;
    }

    _bgmEnabled = enabled;

    await SaveService.instance.saveBgmEnabled(enabled);

    if (!enabled) {
      // 재생 중인 곡 이름은 유지하고 음악만 정지합니다.
      await stopBgm(
        clearCurrentBgm: false,
      );
      return;
    }

    // 다시 활성화하면 기억해 둔 BGM을 처음부터 재생합니다.
    final bgm = _currentBgm;

    if (bgm != null) {
      await playBgm(bgm);
    }
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
    unawaited(SaveService.instance.saveSfxEnabled(enabled));
  }

  void setBgmVolume(double volume) {
    _bgmVolume = _normalizeVolume(volume);
    unawaited(SaveService.instance.saveBgmVolume(_bgmVolume));
  }

  void setSfxVolume(double volume) {
    _sfxVolume = _normalizeVolume(volume);
    unawaited(SaveService.instance.saveSfxVolume(_sfxVolume));
  }

  Future<void> resetSettings() async {
    await SaveService.instance.resetAudioSettings();

    _bgmEnabled = AudioSettings.defaults.bgmEnabled;
    _sfxEnabled = AudioSettings.defaults.sfxEnabled;
    _bgmVolume = AudioSettings.defaults.bgmVolume;
    _sfxVolume = AudioSettings.defaults.sfxVolume;
  }

  double _normalizeVolume(double volume) {
    return volume.clamp(0.0, 1.0).toDouble();
  }
}
