import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/audio/app_audio_coordinator.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../../core/haptics/healing_haptics.dart';
import '../../../domain/models/sleep_session.dart';
import '../../../domain/models/sound_asset.dart';
import '../../../domain/repositories/sound_repository.dart';
import '../../navigation/app_navigation.dart';
import '../../tabs/home/home_scene_catalog.dart';
import '../sleep_session_controller.dart';
import '../widgets/sleep_companion_timer_sheet.dart';

class SleepSessionPage extends GetView<SleepSessionController> {
  const SleepSessionPage({super.key});

  static const _soundLabels = {
    'valley_rain': '山谷雨声',
    'ocean_waves': '海边浪声',
    'pine_forest': '林间风声',
  };

  static String labelForSound(String? soundId) {
    if (soundId == null) return '森林';
    final fromPicker = _soundLabels[soundId];
    if (fromPicker != null) return fromPicker;
    for (final scene in HomeSceneCatalog.scenes) {
      if (scene.id == soundId) return scene.title;
    }
    if (Get.isRegistered<AppAudioCoordinator>()) {
      final title = Get.find<AppAudioCoordinator>().nowPlayingTitle.value;
      if (title != null && title.isNotEmpty) return title;
    }
    return soundId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1218),
      body: Obx(() {
        final session = controller.session.value;
        if (session == null) {
          return SafeArea(child: _IdleBody(layout: HealingLayout.of(context)));
        }
        return PopScope(
          canPop: false,
          child: _ActiveBody(
            layout: HealingLayout.of(context),
            session: session,
          ),
        );
      }),
    );
  }
}

class _IdleBody extends GetView<SleepSessionController> {
  const _IdleBody({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(layout.pagePad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: layout.pt(24)),
          Text(
            '今晚睡眠监测',
            style: HealingDesignSystem.heroDisplay.copyWith(
              fontSize: layout.fontPageTitle * 1.1,
            ),
          ),
          SizedBox(height: layout.pt(12)),
          Text(
            '请佩戴已连接的云遥戒指，点击下方开始采集。监测过程中可选择伴睡声景。',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: layout.fontAssist,
              height: 1.45,
            ),
          ),
          Obx(() {
            final pending = controller.pendingSoundId.value;
            if (pending == null) return const SizedBox.shrink();
            final label = SleepSessionPage.labelForSound(pending);
            return Padding(
              padding: EdgeInsets.only(top: layout.pt(16)),
              child: Text(
                '已选伴睡：$label',
                style: TextStyle(
                  color: const Color(0xFFB0A4FF),
                  fontSize: layout.fontAssist,
                ),
              ),
            );
          }),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => openSleepPicker(forCompanion: true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB0A4FF),
              side: const BorderSide(color: Color(0x66B0A4FF)),
              minimumSize: Size.fromHeight(layout.pt(48)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMoon,
              size: layout.pt(20),
              color: const Color(0xFFB0A4FF),
            ),
            label: Text(
              '先选伴睡声景（可选）',
              style: TextStyle(fontSize: layout.fontButton),
            ),
          ),
          SizedBox(height: layout.cardGap),
          FilledButton(
            onPressed: () async {
              HealingHaptics.medium();
              await controller.start();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9D91F2),
              minimumSize: Size.fromHeight(layout.pt(52)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: Text(
              '开始今晚监测',
              style: TextStyle(
                fontSize: layout.fontButton,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBody extends StatefulWidget {
  const _ActiveBody({required this.layout, required this.session});
  final HealingLayout layout;
  final SleepSession session;

  @override
  State<_ActiveBody> createState() => _ActiveBodyState();
}

class _ActiveBodyState extends State<_ActiveBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _endProgress;
  var _holding = false;
  var _finishing = false;

  HealingLayout get layout => widget.layout;
  SleepSessionController get controller => Get.find<SleepSessionController>();

  @override
  void initState() {
    super.initState();
    _endProgress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          unawaited(_completeEnd());
        }
      });
  }

  @override
  void dispose() {
    _endProgress.dispose();
    super.dispose();
  }

  void _onHoldStart(PointerDownEvent _) {
    if (_finishing) return;
    setState(() => _holding = true);
    HealingHaptics.selection();
    _endProgress.forward(from: 0);
  }

  void _onHoldEnd(PointerEvent _) {
    if (_finishing) return;
    if (_endProgress.status == AnimationStatus.completed) return;
    _endProgress.stop();
    _endProgress.value = 0;
    if (_holding) setState(() => _holding = false);
  }

  Future<void> _completeEnd() async {
    if (_finishing) return;
    _finishing = true;
    HealingHaptics.medium();
    final ended = await controller.endAndSave();
    if (!mounted) return;
    await Get.offNamed('/sleep/report', arguments: ended);
  }

  Future<void> _openCompanionPlayer() async {
    if (_finishing) return;
    final soundId =
        controller.session.value?.soundId ??
        controller.pendingSoundId.value ??
        HomeSceneCatalog.scenes.first.id;
    await controller.attachCompanion(soundId);
    openPlayer(
      soundId,
      displayTitle: SleepSessionPage.labelForSound(soundId),
      displaySubtitle: controller.subtitleForSound(soundId),
    );
  }

  Future<void> _toggleCompanionPlayback() async {
    if (_finishing) return;
    if (!Get.isRegistered<AppAudioCoordinator>()) return;
    final audio = Get.find<AppAudioCoordinator>();
    final soundId =
        controller.session.value?.soundId ??
        controller.pendingSoundId.value ??
        HomeSceneCatalog.scenes.first.id;

    if (audio.hasPlayerSession) {
      await audio.togglePlayerPlayPause();
      return;
    }

    await controller.attachCompanion(soundId);
    openPlayer(
      soundId,
      displayTitle: SleepSessionPage.labelForSound(soundId),
      displaySubtitle: controller.subtitleForSound(soundId),
    );
  }

  Future<void> _showQuickSoundsSheet() async {
    if (_finishing) return;
    List<SoundAsset> items = const [];
    if (Get.isRegistered<SoundRepository>()) {
      items = await Get.find<SoundRepository>().listFavorites();
    }
    if (items.isEmpty) {
      items = HomeSceneCatalog.soundAssets.take(6).toList(growable: false);
    }
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A2233),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              layout.pt(20),
              layout.pt(12),
              layout.pt(20),
              layout.pt(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: layout.pt(40),
                    height: layout.pt(4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                SizedBox(height: layout.pt(16)),
                Text(
                  '常听白噪音',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: layout.fontPageTitle * 0.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: layout.pt(12)),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: layout.pt(360)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => SizedBox(height: layout.pt(8)),
                    itemBuilder: (context, index) {
                      final sound = items[index];
                      return Material(
                        color: const Color(0x33283367),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            await controller.attachCompanion(sound.id);
                            openPlayer(
                              sound.id,
                              displayTitle: sound.title,
                              displaySubtitle: sound.subtitle,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: layout.pt(14),
                              vertical: layout.pt(12),
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedMusicNote01,
                                  size: layout.pt(22),
                                  color: Colors.white70,
                                ),
                                SizedBox(width: layout.pt(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sound.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: layout.fontButton,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (sound.subtitle.isNotEmpty)
                                        Text(
                                          sound.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: layout.fontAssist,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/sleep_monitoring/backgrounds/background_sleep_monitoring.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x26031028), Color(0x00031028), Color(0xAA030B28)],
              stops: [0, 0.48, 1],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              layout.pagePad,
              layout.pt(8),
              layout.pagePad,
              layout.pt(18),
            ),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Obx(() {
                  final now = controller.wallClock.value;
                  final hh = now.hour.toString().padLeft(2, '0');
                  final mm = now.minute.toString().padLeft(2, '0');
                  return Column(
                    children: [
                      _MonitoringTime(
                        minutes: hh,
                        seconds: mm,
                        layout: layout,
                      ),
                      SizedBox(height: layout.pt(10)),
                      Text(
                        controller.companionCountdownLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: layout.fontAssist,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: layout.pt(16)),
                Obx(
                  () => _MonitoringPill(
                    icon: HugeIcons.strokeRoundedAlarmClock,
                    label: controller.timerWindowLabel,
                    layout: layout,
                    onTap: _finishing
                        ? null
                        : () => showSleepCompanionTimerSheet(context),
                  ),
                ),
                Obx(() {
                  if (!controller.showHeartRate.value) {
                    return const SizedBox.shrink();
                  }
                  final bpm = controller.liveBpm.value;
                  return Padding(
                    padding: EdgeInsets.only(top: layout.pt(10)),
                    child: _MonitoringPill(
                      icon: HugeIcons.strokeRoundedPulse01,
                      label: bpm == null ? '心率  —' : '心率  $bpm bpm',
                      layout: layout,
                    ),
                  );
                }),
                const Spacer(flex: 3),
                Listener(
                  onPointerDown: _onHoldStart,
                  onPointerUp: _onHoldEnd,
                  onPointerCancel: _onHoldEnd,
                  child: Semantics(
                    button: true,
                    label: '长按结束睡眠监测',
                    child: Container(
                      width: layout.pt(108),
                      height: layout.pt(108),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x55283367),
                        border: Border.all(color: const Color(0x40FFFFFF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedStop,
                          size: layout.pt(36),
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: layout.pt(14)),
                AnimatedBuilder(
                  animation: _endProgress,
                  builder: (context, _) {
                    if (!_holding && !_finishing) {
                      return SizedBox(height: layout.pt(10));
                    }
                    return SizedBox(
                      width: layout.pt(120),
                      height: layout.pt(10),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _endProgress.value,
                            minHeight: layout.pt(3),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.18,
                            ),
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: layout.pt(18)),
                Obx(() {
                  final soundId = controller.session.value?.soundId;
                  final soundLabel = SleepSessionPage.labelForSound(soundId);
                  final subtitle = controller.subtitleForSound(soundId);
                  final audio = Get.isRegistered<AppAudioCoordinator>()
                      ? Get.find<AppAudioCoordinator>()
                      : null;
                  final playing = audio?.isPlaying.value ?? false;
                  final hasSession = audio?.hasPlayerSession ?? false;
                  // Touch nowPlaying fields so subtitle refreshes with session.
                  audio?.nowPlayingSubtitle.value;
                  return Row(
                    children: [
                      _RoundControl(
                        size: layout.pt(58),
                        icon: HugeIcons.strokeRoundedStopWatch,
                        semanticLabel: '伴睡定时器',
                        onTap: _finishing
                            ? null
                            : () => showSleepCompanionTimerSheet(context),
                      ),
                      SizedBox(width: layout.pt(14)),
                      Expanded(
                        child: _SoundControl(
                          label: soundLabel,
                          subtitle: subtitle,
                          layout: layout,
                          playing: hasSession && playing,
                          onOpenPlayer:
                              _finishing ? null : _openCompanionPlayer,
                          onPlayPauseTap:
                              _finishing ? null : _toggleCompanionPlayback,
                        ),
                      ),
                      SizedBox(width: layout.pt(14)),
                      _RoundControl(
                        size: layout.pt(58),
                        icon: HugeIcons.strokeRoundedGridView,
                        semanticLabel: '常听白噪音',
                        onTap: _finishing ? null : _showQuickSoundsSheet,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonitoringTime extends StatelessWidget {
  const _MonitoringTime({
    required this.minutes,
    required this.seconds,
    required this.layout,
  });

  final String minutes;
  final String seconds;
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final style = HealingDesignSystem.heroDisplay.copyWith(
      color: Colors.white,
      fontSize: layout.pt(78),
      fontWeight: FontWeight.w300,
      height: 0.9,
      shadows: const [Shadow(color: Color(0x55000000), blurRadius: 18)],
    );
    return Column(
      children: [
        Text(minutes, style: style),
        SizedBox(height: layout.pt(8)),
        Text(seconds, style: style.copyWith(color: const Color(0xBFFFFFFF))),
      ],
    );
  }
}

class _MonitoringPill extends StatelessWidget {
  const _MonitoringPill({
    required this.icon,
    required this.label,
    required this.layout,
    this.onTap,
  });

  final List<List<dynamic>> icon;
  final String label;
  final HealingLayout layout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: layout.pt(16),
        vertical: layout.pt(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0x4A8790CE),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            size: layout.pt(22),
            color: Colors.white.withValues(alpha: 0.92),
          ),
          SizedBox(width: layout.pt(10)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: layout.fontButton,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.size,
    required this.icon,
    required this.semanticLabel,
    this.onTap,
  });

  final double size;
  final List<List<dynamic>> icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0x45283367),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: Center(
        child: HugeIcon(
          icon: icon,
          size: size * 0.42,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
    if (onTap == null) {
      return Semantics(label: semanticLabel, child: content);
    }
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: content,
      ),
    );
  }
}

class _SoundControl extends StatelessWidget {
  const _SoundControl({
    required this.label,
    required this.subtitle,
    required this.layout,
    required this.playing,
    required this.onOpenPlayer,
    required this.onPlayPauseTap,
  });

  final String label;
  final String subtitle;
  final HealingLayout layout;
  final bool playing;
  final VoidCallback? onOpenPlayer;
  final VoidCallback? onPlayPauseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.pt(58),
      padding: EdgeInsets.only(left: layout.pt(10), right: layout.pt(4)),
      decoration: BoxDecoration(
        color: const Color(0x52353D70),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: '打开播放器',
              child: InkWell(
                onTap: onOpenPlayer,
                borderRadius: BorderRadius.circular(99),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(layout.pt(12)),
                      child: Image.asset(
                        'assets/images/home/home_bg/森林溪流.PNG',
                        width: layout.pt(42),
                        height: layout.pt(42),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: layout.pt(10)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: layout.fontButton,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: layout.fontAssist,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: playing ? '暂停伴睡' : '播放伴睡',
            child: InkWell(
              onTap: onPlayPauseTap,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(layout.pt(10)),
                child: HugeIcon(
                  icon: playing
                      ? HugeIcons.strokeRoundedPause
                      : HugeIcons.strokeRoundedPlay,
                  size: layout.pt(22),
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
