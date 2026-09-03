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

  final status = PlayerStatus.idle.obs;
  final sound = Rxn<SoundAsset>();
  final coverImageAsset = RxnString();
  final displayTitle = RxnString();
  final displaySubtitle = RxnString();
  final isFavorite = false.obs;
  final elapsedSeconds = 0.obs;
  final countdownMinutes = 30.obs;
  final errorMessage = RxnString();
  final showResumeHint = false.obs;

  StreamSubscription<Duration>? _positionSub;

  @override
  void onInit() {
    super.onInit();
    _positionSub = _audioPlayer.positionStream.listen(_onPosition);
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
    _positionSub?.cancel();
    super.onClose();
  }

  void _onPosition(Duration position) {
    elapsedSeconds.value = position.inSeconds;
    final limit = countdownMinutes.value * 60;
    if (status.value == PlayerStatus.playing &&
        limit > 0 &&
        elapsedSeconds.value >= limit) {
      unawaited(_pause());
    }
  }

  Future<void> load(String soundId) async {
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
      } else {
        elapsedSeconds.value = 0;
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

  Future<void> _play() async {
    final current = sound.value;
    if (current == null) return;
    try {
      status.value = PlayerStatus.loading;
      await _audio.playSoundAsset(current.id, current);
      status.value = PlayerStatus.playing;
    } catch (_) {
      status.value = PlayerStatus.error;
      errorMessage.value = '播放失败，请重试';
      return;
    }
    HealingHaptics.light();
  }

  Future<void> _pause() async {
    await _audio.pause();
    status.value = PlayerStatus.paused;
  }

  Future<void> toggleFavorite() async {
    final current = sound.value;
    if (current == null) return;
    await _soundRepository.toggleFavorite(current.id);
    isFavorite.value = await _soundRepository.isFavorite(current.id);
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
