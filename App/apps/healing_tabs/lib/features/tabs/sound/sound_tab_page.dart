import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/design/healing_design_system.dart';
import '../../../core/design/healing_layout.dart';
import '../../navigation/app_navigation.dart';
import '../../root_shell/widgets/glass_widgets.dart';
import '../../settings/pages/settings_sheet.dart';
import '../../sound_catalog/sound_catalog_controller.dart';
import '../../sound_catalog/sound_catalog_helpers.dart';
import '../../sound_catalog/widgets/sound_library_sheet.dart';

class SoundTabPage extends StatelessWidget {
  const SoundTabPage({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        return Obx(() {
          final catalog = Get.find<SoundCatalogController>();
          final sounds = catalog.sounds;
          final hero = pickSound(sounds, 'white_noise') ??
              pickSound(sounds, 'valley_rain');
          final listItem = pickSound(sounds, 'valley_rain') ??
              pickSound(sounds, 'ocean_waves', fallbackIndex: 1);

          return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              HealingAssets.background(HealingRootTab.sound),
              fit: BoxFit.cover,
            ),
            Positioned(
              left: layout.dx(78),
              top: layout.dy(152),
              child: Text(
                '声音',
                style: HealingDesignSystem.pageTitle.copyWith(
                  fontSize: layout.sz(82),
                  letterSpacing: layout.sz(1.6),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(514),
              top: layout.dy(152),
              child: GestureDetector(
                onTap: () => showSoundLibrarySheet(context),
                child: GlassCircleButton(
                  asset: HealingAssets.searchButton(HealingRootTab.sound),
                  size: layout.sz(96),
                  iconSize: layout.sz(48),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(636),
              top: layout.dy(152),
              width: layout.sz(122),
              height: layout.sz(90),
              child: GestureDetector(
                onTap: () => showSoundLibrarySheet(context),
                child: GlassDarkPanel(
                  borderRadius: layout.sz(999),
                  child: Center(
                    child: Image.asset(
                      HealingAssets.addButton(HealingRootTab.sound),
                      width: layout.sz(54),
                      height: layout.sz(54),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(790),
              top: layout.dy(145),
              width: layout.sz(108),
              height: layout.sz(108),
              child: GestureDetector(
                onTap: () => showSettingsSheet(context),
                child: Image.asset(
                  HealingAssets.profileOrb(HealingRootTab.sound),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(67),
              top: layout.dy(301),
              width: layout.sz(807),
              height: layout.sz(713),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(layout.sz(48)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      HealingAssets.background(HealingRootTab.sound),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    GlassDarkPanel(
                      borderRadius: layout.sz(48),
                      child: const SizedBox.expand(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: layout.dx(91),
              top: layout.dy(354),
              child: Text(
                hero?.title ?? '白噪音时刻',
                style: HealingDesignSystem.heroCardTitle.copyWith(
                  fontSize: layout.sz(52),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(116),
              top: layout.dy(871),
              width: layout.sz(520),
              height: layout.sz(62),
              child: _Waveform(layout: layout),
            ),
            Positioned(
              left: layout.dx(684),
              top: layout.dy(827),
              width: layout.sz(144),
              height: layout.sz(144),
              child: GestureDetector(
                onTap: () {
                  if (hero != null) openPlayer(hero.id);
                },
                child: ClipOval(
                  child: Image.asset(
                    HealingAssets.playButton(HealingRootTab.sound),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(67),
              top: layout.dy(1058),
              width: layout.sz(807),
              height: layout.sz(310),
              child: GestureDetector(
                onTap: () {
                  if (listItem != null) {
                    openPlayer(listItem.id);
                  } else {
                    showSoundLibrarySheet(context);
                  }
                },
                child: GlassDarkPanel(
                  borderRadius: layout.sz(48),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(108),
              top: layout.dy(1097),
              width: layout.sz(226),
              height: layout.sz(226),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(layout.sz(28)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                    borderRadius: BorderRadius.circular(layout.sz(28)),
                  ),
                  child: Image.asset(
                    HealingAssets.background(HealingRootTab.sound),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(364),
              top: layout.dy(1130),
              child: Text(
                listItem?.title ?? '山谷雨声',
                style: HealingDesignSystem.listTitle.copyWith(
                  fontSize: layout.sz(52),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(364),
              top: layout.dy(1194),
              child: Text(
                listItem?.subtitle ?? '专注 · 自然录音',
                style: HealingDesignSystem.listSub.copyWith(
                  fontSize: layout.sz(31),
                ),
              ),
            ),
            Positioned(
              left: layout.dx(358),
              top: layout.dy(1252),
              child: Row(
                children: [
                  for (final tag in listItem?.tags.take(3) ?? ['自然', '雨声', '风声'])
                    Padding(
                      padding: EdgeInsets.only(right: layout.sz(14)),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          border: Border.all(color: const Color(0x24FFFFFF)),
                          borderRadius: BorderRadius.circular(layout.sz(999)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: layout.sz(28),
                            vertical: layout.sz(12),
                          ),
                          child: Text(
                            tag,
                            style: HealingDesignSystem.tagLabel.copyWith(
                              fontSize: layout.sz(31),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
        });
      },
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.layout});

  final HealingLayout layout;

  static const _heights = [0.55, 0.88, 0.42, 0.68, 0.55];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 15; i++)
          Container(
            width: layout.sz(8),
            height: layout.sz(62) * _heights[i % _heights.length],
            margin: EdgeInsets.symmetric(horizontal: layout.sz(5)),
            decoration: BoxDecoration(
              color: const Color(0xC7FFFFFF),
              borderRadius: BorderRadius.circular(layout.sz(4)),
            ),
          ),
      ],
    );
  }
}
