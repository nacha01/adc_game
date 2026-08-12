import 'package:shared_preferences/shared_preferences.dart';

class AudioSettings {
  final bool bgmEnabled;
  final bool sfxEnabled;
  final double bgmVolume;
  final double sfxVolume;

  const AudioSettings({
    required this.bgmEnabled,
    required this.sfxEnabled,
    required this.bgmVolume,
    required this.sfxVolume,
  });

  static const AudioSettings defaults = AudioSettings(
    bgmEnabled: true,
    sfxEnabled: true,
    bgmVolume: 0.4,
    sfxVolume: 1.0,
  );
}

class SaveService {
  SaveService._();

  static final SaveService instance = SaveService._();

  static const String _bgmEnabledKey = 'audio.bgm_enabled';
  static const String _sfxEnabledKey = 'audio.sfx_enabled';
  static const String _bgmVolumeKey = 'audio.bgm_volume';
  static const String _sfxVolumeKey = 'audio.sfx_volume';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<AudioSettings> loadAudioSettings() async {
    final bgmEnabled =
        await _preferences.getBool(_bgmEnabledKey) ??
            AudioSettings.defaults.bgmEnabled;

    final sfxEnabled =
        await _preferences.getBool(_sfxEnabledKey) ??
            AudioSettings.defaults.sfxEnabled;

    final bgmVolume = _normalizeVolume(
      await _preferences.getDouble(_bgmVolumeKey) ??
          AudioSettings.defaults.bgmVolume,
    );

    final sfxVolume = _normalizeVolume(
      await _preferences.getDouble(_sfxVolumeKey) ??
          AudioSettings.defaults.sfxVolume,
    );

    return AudioSettings(
      bgmEnabled: bgmEnabled,
      sfxEnabled: sfxEnabled,
      bgmVolume: bgmVolume,
      sfxVolume: sfxVolume,
    );
  }

  Future<void> saveBgmEnabled(bool enabled) async {
    await _preferences.setBool(_bgmEnabledKey, enabled);
  }

  Future<void> saveSfxEnabled(bool enabled) async {
    await _preferences.setBool(_sfxEnabledKey, enabled);
  }

  Future<void> saveBgmVolume(double volume) async {
    await _preferences.setDouble(
      _bgmVolumeKey,
      _normalizeVolume(volume),
    );
  }

  Future<void> saveSfxVolume(double volume) async {
    await _preferences.setDouble(
      _sfxVolumeKey,
      _normalizeVolume(volume),
    );
  }

  Future<void> resetAudioSettings() async {
    await Future.wait([
      _preferences.remove(_bgmEnabledKey),
      _preferences.remove(_sfxEnabledKey),
      _preferences.remove(_bgmVolumeKey),
      _preferences.remove(_sfxVolumeKey),
    ]);
  }

  double _normalizeVolume(double volume) {
    return volume.clamp(0.0, 1.0).toDouble();
  }
}
