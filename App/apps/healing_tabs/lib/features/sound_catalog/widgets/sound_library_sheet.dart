import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/models/sound_asset.dart';
import '../../../domain/repositories/sound_repository.dart';
import '../../navigation/app_navigation.dart';
import '../../tabs/home/home_scene_catalog.dart';
import '../sound_catalog_controller.dart';

Future<void> showSoundLibrarySheet(BuildContext context) async {
  final sounds = HomeSceneCatalog.soundAssets;
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF141A22),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return _SoundLibrarySheetBody(initialSounds: sounds);
    },
  );
}

class _SoundLibrarySheetBody extends StatefulWidget {
  const _SoundLibrarySheetBody({required this.initialSounds});

  final List<SoundAsset> initialSounds;

  @override
  State<_SoundLibrarySheetBody> createState() => _SoundLibrarySheetBodyState();
}

class _SoundLibrarySheetBodyState extends State<_SoundLibrarySheetBody> {
  late List<SoundAsset> _sounds;
  final _favorites = <String>{};
  var _loadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _sounds = List<SoundAsset>.from(widget.initialSounds);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final repo = Get.find<SoundRepository>();
    final favs = await repo.listFavorites();
    if (!mounted) return;
    setState(() {
      _favorites
        ..clear()
        ..addAll(favs.map((s) => s.id));
      _loadingFavorites = false;
    });
  }

  Future<void> _toggleFavorite(SoundAsset sound) async {
    final repo = Get.find<SoundRepository>();
    await repo.toggleFavorite(sound.id);
    await _loadFavorites();
    if (Get.isRegistered<SoundCatalogController>()) {
      await Get.find<SoundCatalogController>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '场景库',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '共 ${_sounds.length} 种场景 · 轻触播放回到首页',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (_loadingFavorites)
                const LinearProgressIndicator(minHeight: 2)
              else
                const SizedBox(height: 2),
              const SizedBox(height: 8),
              Expanded(
                child: _sounds.isEmpty
                    ? const Center(
                        child: Text(
                          '暂无场景',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _sounds.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Color(0x1FFFFFFF),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final sound = _sounds[index];
                          final isFavorite = _favorites.contains(sound.id);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              sound.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              sound.subtitle,
                              style: const TextStyle(color: Colors.white54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _toggleFavorite(sound),
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.pinkAccent
                                        : Colors.white54,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    openHomeScene(sound.id, autoplay: true);
                                  },
                                  icon: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
