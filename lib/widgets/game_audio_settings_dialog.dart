import 'package:flutter/material.dart';

import '../services/game_audio_service.dart';

/// adc_game 플랫폼 공통 사운드 설정창
///
/// 배경음악/효과음 사용 여부와 볼륨을 설정합니다.
/// 변경된 설정은 GameAudioService를 통해 로컬에 저장됩니다.
class GameAudioSettingsDialog extends StatefulWidget {
  const GameAudioSettingsDialog({super.key});

  /// 공통 사운드 설정창을 표시합니다.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GameAudioSettingsDialog(),
    );
  }

  @override
  State<GameAudioSettingsDialog> createState() =>
      _GameAudioSettingsDialogState();
}

class _GameAudioSettingsDialogState
    extends State<GameAudioSettingsDialog> {
  final GameAudioService _audioService =
      GameAudioService.instance;

  late bool _bgmEnabled;
  late bool _sfxEnabled;

  late double _bgmVolume;
  late double _sfxVolume;

  @override
  void initState() {
    super.initState();

    _bgmEnabled = _audioService.bgmEnabled;
    _sfxEnabled = _audioService.sfxEnabled;
    _bgmVolume = _audioService.bgmVolume;
    _sfxVolume = _audioService.sfxVolume;
  }

  Future<void> _saveSettings() async {
    await _audioService.setBgmEnabled(_bgmEnabled);

    _audioService.setSfxEnabled(_sfxEnabled);
    _audioService.setBgmVolume(_bgmVolume);
    _audioService.setSfxVolume(_sfxVolume);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Text(
        '사운드 설정',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('배경음악 사용'),
              value: _bgmEnabled,
              onChanged: (value) {
                setState(() {
                  _bgmEnabled = value;
                });
              },
            ),
            Text(
              '배경음악 볼륨: '
                  '${(_bgmVolume * 100).round()}%',
            ),
            Slider(
              value: _bgmVolume,
              onChanged: _bgmEnabled
                  ? (value) {
                setState(() {
                  _bgmVolume = value;
                });
              }
                  : null,
            ),
            const Divider(height: 28),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('효과음 사용'),
              value: _sfxEnabled,
              onChanged: (value) {
                setState(() {
                  _sfxEnabled = value;
                });
              },
            ),
            Text(
              '효과음 볼륨: '
                  '${(_sfxVolume * 100).round()}%',
            ),
            Slider(
              value: _sfxVolume,
              onChanged: _sfxEnabled
                  ? (value) {
                setState(() {
                  _sfxVolume = value;
                });
              }
                  : null,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _saveSettings,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE62D2D),
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}