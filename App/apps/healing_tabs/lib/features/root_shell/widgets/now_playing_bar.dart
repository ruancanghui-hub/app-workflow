import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/audio/app_audio_coordinator.dart';
import '../../../core/design/healing_layout.dart';
import '../../navigation/app_navigation.dart';

/// Tab 栏上方的正在播放条：封面、标题、暂停/继续、停止；点条回播放器。
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  static const _fallbackCover =
      'assets/images/player/backgrounds/background_player_scene.png';

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppAudioCoordinator>()) {
      return const SizedBox.shrink();
    }
    final audio = Get.find<AppAudioCoordinator>();
    final layout = HealingLayout.of(context);

    return Obx(() {
      if (!audio.hasPlayerSession) {
        return const SizedBox.shrink();
      }

      final title = audio.nowPlayingTitle.value ?? '正在播放';
      final subtitle = audio.nowPlayingSubtitle.value ?? '';
      final cover = audio.nowPlayingCover.value;
      final playing = audio.isPlaying.value;
      final barHeight = layout.miniPlayerHeight;
      final iconSize = layout.pt(24);
      final coverSize = layout.pt(40);
      final sidePad = layout.pagePad;

      return Positioned(
        left: sidePad,
        right: sidePad,
        top: layout.nowPlayingBarTop(context),
        height: barHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(layout.radiusContent),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Material(
              color: const Color(0xE61A2430),
              child: InkWell(
                onTap: openNowPlayingPlayer,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: layout.pt(10)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(layout.pt(8)),
                        child: Image.asset(
                          (cover != null && cover.isNotEmpty)
                              ? cover
                              : _fallbackCover,
                          width: coverSize,
                          height: coverSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                            color: const Color(0xFF243044),
                            child: SizedBox(
                              width: coverSize,
                              height: coverSize,
                              child: Icon(
                                Icons.music_note_rounded,
                                color: const Color(0xFF9AA0B9),
                                size: layout.pt(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: layout.pt(10)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: layout.fontCardTitle,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (subtitle.isNotEmpty) ...[
                              SizedBox(height: layout.pt(2)),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF9AA0B9),
                                  fontSize: layout.fontAssist,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: playing ? '暂停' : '继续',
                        onPressed: () => audio.togglePlayerPlayPause(),
                        icon: HugeIcon(
                          icon: playing
                              ? HugeIcons.strokeRoundedPause
                              : HugeIcons.strokeRoundedPlay,
                          size: iconSize,
                          color: const Color(0xFFFDF1DA),
                        ),
                      ),
                      IconButton(
                        tooltip: '停止',
                        onPressed: () => audio.stopPlayer(),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedStop,
                          size: iconSize,
                          color: const Color(0xFFFDF1DA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
