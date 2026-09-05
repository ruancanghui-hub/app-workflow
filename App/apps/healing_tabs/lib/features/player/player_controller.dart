import 'dart:async';

import 'package:get/get.dart';

import '../../core/audio/app_audio_coordinator.dart';
import '../../core/haptics/healing_haptics.dart';
import '../../domain/models/sound_asset.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/repositories/sound_repository.dart';
import '../../domain/services/sound_audio_player.dart';
import '../player/player_launch_args.dart';
import '../sleep_session/sleep_session_controller.dart';

enum PlayerStatus { idle, loading, playing, paused, error }

class PlayerController extends GetxController {
  PlayerController({
    required SoundRepository soundRepository,
    required SleepRepository sleepRepository,
    required SoundAudioPlayer audioPlayer,
    required AppAudioCoordinator audioCoordinator,
  })  : _soundRepository = soundRepository,
        _sleepRepository = sleepRepository,
        _audioPlayer = audioPlayer,
        _audio = audioCoordinator;

  final SoundRepository _soundRepository;
  final SleepRepository _sleepRepository;
  final SoundAudioPlayer _audioPlayer;
  final AppAudioCoordinator _audio;

  /// 循环白噪音的默认会话时长（分钟）。
  static const defaultSessionMinutes = 25;

  final status = PlayerStatus.idle.obs;
  final sound = Rxn<SoundAsset>();
  final coverImageAsset = RxnString();
  final displayTitle = RxnString();
  final displaySubtitle = RxnString();
  final isFavorite = false.obs;
  /// 当前会话已播放秒数（相对定时器，非音轨绝对位置）。
  final elapsedSeconds = 0.obs;
  final countdownMinutes = defaultSessionMinutes.obs;
  final errorMessage = RxnString();
  final showResumeHint = false.obs;
  /// 仅首次加载素材时为 true；开播不转圈。
  final isBootstrapping = false.obs;

  Timer? _sessionTick;
  DateTime? _playAnchor;
  var _elapsedBaseSeconds = 0;
  Worker? _playingWorker;

  int get sessionTotalSeconds => countdownMinutes.value * 60;

  double get sessionProgress {
    final total = sessionTotalSeconds;
    if (total <= 0) return 0;
    return (elapsedSeconds.value / total).clamp(0.0, 1.0);
  }

  @override
  void onInit() {
    super.onInit();
    _playingWorker = ever<bool>(_audio.isPlaying, (playing) {
      if (!_audio.isPlayerSoundSession(sound.value?.id ?? '')) return;
      if (playing) {
        if (status.value != PlayerStatus.playing) {
          status.value = PlayerStatus.playing;
          _armSessionTick();
        }
      } else if (status.value == PlayerStatus.playing) {
        status.value = PlayerStatus.paused;
        _disarmSessionTick(commit: true);
      }
    });
    final args = Get.arguments;
    if (args is PlayerLaunchArgs) {
      coverImageAsset.value = args.coverImageAsset;
      displayTitle.value = args.displayTitle;
      displaySubtitle.value = args.displaySubtitle;
    }
    final id = Get.parameters['soundId'];
    if (id != null && id.isNotEmpty) {
      load(id);
    }
  }

  @override
  void onClose() {
    _playingWorker?.dispose();
    _sessionTick?.cancel();
    super.onClose();
  }

  Future<void> load(String soundId) async {
    isBootstrapping.value = true;
    status.value = PlayerStatus.loading;
    errorMessage.value = null;
    try {
      final asset = await _soundRepository.findById(soundId);
      if (asset == null) {
        status.value = PlayerStatus.error;
        errorMessage.value = '声景不存在';
        return;
      }
      sound.value = asset;
      isFavorite.value = await _soundRepository.isFavorite(soundId);
      if (_audio.isPlayerSoundPlaying(soundId)) {
        status.value = PlayerStatus.playing;
        showResumeHint.value = false;
        _armSessionTick();
      } else if (_audio.isPlayerSoundSession(soundId)) {
        status.value = PlayerStatus.paused;
        showResumeHint.value = false;
      } else {
        elapsedSeconds.value = 0;
        _elapsedBaseSeconds = 0;
        status.value = PlayerStatus.paused;
      }
    } on StateError catch (e) {
      status.value = PlayerStatus.error;
      errorMessage.value = e.message.contains('SOUND_CDN_BASE_URL')
          ? '该声景需联网加载，请稍后重试'
          : '加载失败，请重试';
    } catch (_) {
      status.value = PlayerStatus.error;
      errorMessage.value = '加载失败，请重试';
    } finally {
      isBootstrapping.value = false;
    }
  }

  Future<void> togglePlay() async {
    showResumeHint.value = false;
    if (status.value == PlayerStatus.playing) {
      await _pause();
    } else if (sound.value != null && status.value != PlayerStatus.loading) {
      await _play();
    }
  }

  Future<void> pauseForInterruption() async {
    if (status.value == PlayerStatus.playing) {
      await _pause();
      showResumeHint.value = true;
    }
  }

  Future<void> seekBySeconds(int deltaSeconds) async {
    final current = await _audioPlayer.position;
    var next = current + Duration(seconds: deltaSeconds);
    if (next.isNegative) next = Duration.zero;
    final track = _audioPlayer.duration;
    if (track != null && track.inMilliseconds > 0) {
      next = Duration(
        milliseconds: next.inMilliseconds % track.inMilliseconds,
      );
    }
    await _audioPlayer.seek(next);

    final sessionNext =
        (elapsedSeconds.value + deltaSeconds).clamp(0, sessionTotalSeconds);
    elapsedSeconds.value = sessionNext;
    _elapsedBaseSeconds = sessionNext;
    if (_playAnchor != null) {
      _playAnchor = DateTime.now();
    }
  }

  Future<void> seekSessionFraction(double fraction) async {
    final target = (fraction.clamp(0.0, 1.0) * sessionTotalSeconds).round();
    final delta = target - elapsedSeconds.value;
    elapsedSeconds.value = target;
    _elapsedBaseSeconds = target;
    if (_playAnchor != null) {
      _playAnchor = DateTime.now();
    }

    final track = _audioPlayer.duration;
    if (track != null && track.inMilliseconds > 0) {
      final ms = target * 1000 % track.inMilliseconds;
      await _audioPlayer.seek(Duration(milliseconds: ms));
    } else {
      final current = await _audioPlayer.position;
      var next = current + Duration(seconds: delta);
      if (next.isNegative) next = Duration.zero;
      await _audioPlayer.seek(next);
    }

    if (target >= sessionTotalSeconds && status.value == PlayerStatus.playing) {
      await _pause();
    }
  }

  void setCountdownMinutes(int minutes) {
    if (minutes <= 0) return;
    countdownMinutes.value = minutes;
    if (elapsedSeconds.value > sessionTotalSeconds) {
      elapsedSeconds.value = sessionTotalSeconds;
      _elapsedBaseSeconds = elapsedSeconds.value;
    }
  }

  Future<void> _play() async {
    final current = sound.value;
    if (current == null) return;
    // 先切到播放态，避免转圈、保证按钮立刻变为暂停。
    status.value = PlayerStatus.playing;
    _armSessionTick();
    try {
      final sameSession = _audio.isPlayerSoundSession(current.id);
      if (sameSession && !_audio.isPlaying.value) {
        await _audio.resume();
      } else if (!(sameSession && _audio.isPlaying.value)) {
        await _audio.playSoundAsset(
          current.id,
          current,
          title: displayTitle.value ?? current.title,
          subtitle: displaySubtitle.value ?? current.subtitle,
          coverImageAsset: coverImageAsset.value,
        );
        // 新开播重置会话进度
        elapsedSeconds.value = 0;
        _elapsedBaseSeconds = 0;
        _playAnchor = DateTime.now();
      }
    } catch (_) {
      _disarmSessionTick(commit: true);
      status.value = PlayerStatus.error;
      errorMessage.value = '播放失败，请重试';
      return;
    }
    HealingHaptics.light();
  }

  Future<void> _pause() async {
    _disarmSessionTick(commit: true);
    await _audio.pause();
    status.value = PlayerStatus.paused;
  }

  void _armSessionTick() {
    _sessionTick?.cancel();
    _playAnchor = DateTime.now();
    _sessionTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_playAnchor == null) return;
      final live = _elapsedBaseSeconds +
          DateTime.now().difference(_playAnchor!).inSeconds;
      elapsedSeconds.value = live.clamp(0, sessionTotalSeconds);
      if (elapsedSeconds.value >= sessionTotalSeconds) {
        unawaited(_pause());
      }
    });
  }

  void _disarmSessionTick({required bool commit}) {
    if (commit && _playAnchor != null) {
      _elapsedBaseSeconds = elapsedSeconds.value;
    }
    _sessionTick?.cancel();
    _sessionTick = null;
    _playAnchor = null;
  }

  Future<void> toggleFavorite() async {
    final current = sound.value;
    if (current == null) return;
    await _soundRepository.toggleFavorite(current.id);
    isFavorite.value = await _soundRepository.isFavorite(current.id);
    HealingHaptics.light();
  }

  Future<void> startSleepSession() async {
    final current = sound.value;
    if (current == null) return;
    await _pause();
    HealingHaptics.medium();
    if (!Get.isRegistered<SleepSessionController>()) {
      Get.put(
        SleepSessionController(sleepRepository: _sleepRepository),
        permanent: true,
      );
    }
    await Get.find<SleepSessionController>().start(soundId: current.id);
    await Get.toNamed('/sleep/session');
  }
}
