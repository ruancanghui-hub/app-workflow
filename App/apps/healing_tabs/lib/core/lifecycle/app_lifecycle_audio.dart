import 'package:flutter/widgets.dart';

import '../audio/app_audio_coordinator.dart';

/// 保留生命周期观察挂载点；后台/锁屏播放由系统音频会话与 audio_service 维持，
/// 不再在切后台时主动暂停。
class AppLifecycleAudio extends WidgetsBindingObserver {
  AppLifecycleAudio(this._audio);

  // Kept for future interruption hooks (e.g. phone call).
  // ignore: unused_field
  final AppAudioCoordinator _audio;

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Intentionally empty: do not pause on paused/inactive.
  }
}
