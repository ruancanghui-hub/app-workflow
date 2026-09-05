import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/assets/healing_assets.dart';
import '../../../core/audio/app_audio_coordinator.dart';
import '../../../core/design/healing_layout.dart';
import '../../../domain/models/meditation_content.dart';
import '../../navigation/app_navigation.dart';
import 'meditation_content_catalog.dart';

class MeditationTabPage extends StatefulWidget {
  const MeditationTabPage({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HealingRootTab activeTab;
  final ValueChanged<HealingRootTab> onTabSelected;

  @override
  State<MeditationTabPage> createState() => _MeditationTabPageState();
}

class _MeditationTabPageState extends State<MeditationTabPage> {
  final _scrollController = ScrollController();
  final _sectionKeys = <String, GlobalKey>{};
  var _selectedChip = 0;

  static const _chips = [
    '全部',
    '快速减压',
    '情绪急救',
    '自我成长',
    '职场喘息',
    '备考静心',
    '日间活力',
    '社交修复',
    '精选专题',
  ];

  static const _chipToId = <int, String>{
    1: 'quick_relief',
    2: 'emotion_first_aid',
    3: 'self_growth',
    4: 'workplace',
    5: 'study_focus',
    6: 'daytime_energy',
    7: 'social_repair',
    8: 'multi_day_series',
  };

  GlobalKey _sectionKey(String id) =>
      _sectionKeys.putIfAbsent(id, GlobalKey.new);

  void _selectCategoryAndScroll(MeditationContentCategory category) {
    final entry = _chipToId.entries.firstWhere(
      (e) => e.value == category.id,
      orElse: () => const MapEntry(0, ''),
    );
    setState(() => _selectedChip = entry.key);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _sectionKey(category.id).currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        return Obx(() {
          final audio = Get.find<AppAudioCoordinator>();
          final bottomSpace =
              layout.tabBarDockedHeight +
              layout.tabBarBottomInset(context) +
              layout.sz(28) +
              layout.miniPlayerClearance(visible: audio.hasPlayerSession);
          final categories = _visibleCategories;
          return Stack(
          fit: StackFit.expand,
          children: [
            const _MeditationBackdrop(),
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (MediaQuery.paddingOf(context).top > 0)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StatusBarShieldDelegate(
                      topInset: MediaQuery.paddingOf(context).top,
                      color: const Color(0xFFF7F3EB),
                    ),
                  ),
                SliverToBoxAdapter(child: _TopHeader(layout: layout)),
                SliverToBoxAdapter(
                  child: _DepartGrid(
                    layout: layout,
                    categories:
                        MeditationContentCatalog.categories.take(4).toList(),
                    onTapCategory: _selectCategoryAndScroll,
                  ),
                ),
                SliverToBoxAdapter(child: _HeroBanner(layout: layout)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyChipHeaderDelegate(
                    layout: layout,
                    backgroundColor: const Color(0xFFF7F3EB),
                    child: _ChipRow(
                      layout: layout,
                      chips: _chips,
                      selected: _selectedChip,
                      onSelected: (i) => setState(() => _selectedChip = i),
                    ),
                  ),
                ),
                if (_selectedChip == 0) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      layout: layout,
                      title: '最近使用',
                      showMore: false,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _RecentCapsules(
                      layout: layout,
                      items: MeditationContentCatalog.featured,
                    ),
                  ),
                ],
                for (final category in categories) ...[
                  SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _sectionKey(category.id),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionHeader(
                            layout: layout,
                            title: category.title,
                            onViewAll: () =>
                                openMeditationCategory(category.id),
                          ),
                          if (category.id == 'multi_day_series')
                            _FeaturedPair(
                              layout: layout,
                              items: category.items.take(2).toList(),
                              onTap: openMeditationContent,
                            )
                          else
                            _HorizontalCards(
                              layout: layout,
                              items: category.items,
                              onTap: openMeditationContent,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(child: _InfoCard(layout: layout)),
                SliverToBoxAdapter(child: _MemberBanner(layout: layout)),
                SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
              ],
            ),
          ],
        );
        });
      },
    );
  }

  List<MeditationContentCategory> get _visibleCategories {
    if (_selectedChip == 0) return MeditationContentCatalog.categories;
    final id = _chipToId[_selectedChip];
    if (id == null) return MeditationContentCatalog.categories;
    return MeditationContentCatalog.categories
        .where((c) => c.id == id)
        .toList();
  }
}


class _MeditationBackdrop extends StatelessWidget {
  const _MeditationBackdrop();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF7F3EB), Color(0xFFEEF5F0), Color(0xFFE8F1EA)],
      ),
    ),
  );
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        top + layout.pt(8),
        layout.pagePad,
        layout.moduleSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '冥想',
            style: TextStyle(
              color: const Color(0xFF2C3338),
              fontSize: layout.fontPageTitle,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          SizedBox(height: layout.sz(10)),
          Text(
            '慢一点，也没关系',
            style: TextStyle(
              color: const Color(0xFF6B634F),
              fontSize: layout.fontIntro,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartGrid extends StatelessWidget {
  const _DepartGrid({
    required this.layout,
    required this.categories,
    required this.onTapCategory,
  });

  final HealingLayout layout;
  final List<MeditationContentCategory> categories;
  final ValueChanged<MeditationContentCategory> onTapCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        0,
        layout.pagePad,
        layout.moduleSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: layout.sz(8),
              bottom: layout.sz(14),
            ),
            child: Text(
              '为什么而出发',
              style: TextStyle(
                color: const Color(0xFF2C3338),
                fontSize: layout.fontModuleTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < categories.length; i += 2)
                      Padding(
                        padding: EdgeInsets.only(bottom: layout.cardGap),
                        child: _DepartCard(
                          layout: layout,
                          category: categories[i],
                          tall: i == 0,
                          onTap: () => onTapCategory(categories[i]),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: layout.cardGap),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 1; i < categories.length; i += 2)
                      Padding(
                        padding: EdgeInsets.only(
                          top: i == 1 ? layout.pt(16) : 0,
                          bottom: layout.cardGap,
                        ),
                        child: _DepartCard(
                          layout: layout,
                          category: categories[i],
                          tall: i == 1,
                          onTap: () => onTapCategory(categories[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DepartCard extends StatelessWidget {
  const _DepartCard({
    required this.layout,
    required this.category,
    required this.onTap,
    this.tall = false,
  });

  final HealingLayout layout;
  final MeditationContentCategory category;
  final VoidCallback onTap;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final cover = category.items.first.coverImageAsset;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(layout.radiusDepart),
        child: SizedBox(
          height: layout.sz(tall ? 260 : 200),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(cover, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x22000000), Color(0x990F1A12)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(layout.sz(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      category.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontSecondaryTitle,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    if (category.hint != null) ...[
                      SizedBox(height: layout.sz(6)),
                      Text(
                        category.hint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xE6FFF8EC),
                          fontSize: layout.fontAssist,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final item = MeditationContentCatalog.featured.first;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        0,
        layout.pagePad,
        layout.moduleSpace,
      ),
      child: SizedBox(
        height: layout.pt(160),
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(layout.radiusContent),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(item.coverImageAsset, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x14000000), Color(0x990F1A12)],
                    stops: [0.2, 1],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(layout.sz(28)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: layout.sz(18),
                        vertical: layout.sz(8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x66FFF6E8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '今日推荐',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: layout.fontAssist,
                        ),
                      ),
                    ),
                    SizedBox(height: layout.sz(14)),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontSecondaryTitle,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: layout.sz(8)),
                    Text(
                      '慢一点，也没关系',
                      style: TextStyle(
                        color: const Color(0xF2FFF8EC),
                        fontSize: layout.fontIntro,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: layout.sz(18),
                bottom: layout.sz(18),
                child: GestureDetector(
                  onTap: () => openMeditationFeatured(item),
                  child: Image.asset(
                    HealingAssets.playButton(HealingRootTab.sleep),
                    width: layout.pt(44),
                    height: layout.pt(44),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBarShieldDelegate extends SliverPersistentHeaderDelegate {
  _StatusBarShieldDelegate({required this.topInset, required this.color});

  final double topInset;
  final Color color;

  @override
  double get minExtent => topInset;

  @override
  double get maxExtent => topInset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      SizedBox.expand(
        child: ColoredBox(color: color),
      );

  @override
  bool shouldRebuild(covariant _StatusBarShieldDelegate oldDelegate) =>
      oldDelegate.topInset != topInset || oldDelegate.color != color;
}

class _StickyChipHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyChipHeaderDelegate({
    required this.layout,
    required this.backgroundColor,
    required this.child,
  });

  final HealingLayout layout;
  final Color backgroundColor;
  final Widget child;

  double get _chipHeight => layout.pt(48);

  @override
  double get minExtent => _chipHeight;

  @override
  double get maxExtent => _chipHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Material(
        color: backgroundColor,
        elevation: overlapsContent || shrinkOffset > 0 ? 1 : 0,
        shadowColor: Colors.black26,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyChipHeaderDelegate oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.child != child;
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.layout,
    required this.chips,
    required this.selected,
    required this.onSelected,
  });

  final HealingLayout layout;
  final List<String> chips;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.pt(48),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          layout.pagePad,
          layout.pt(8),
          layout.pagePad,
          layout.pt(4),
        ),
        itemCount: chips.length,
        separatorBuilder: (_, __) => SizedBox(width: layout.chipGap),
        itemBuilder: (context, index) {
          final on = selected == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: layout.pt(14), vertical: layout.pt(8)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on
                    ? const Color(0xE6E6A23C)
                    : const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(layout.radiusChip),
                border: Border.all(
                  color: on
                      ? const Color(0xAAE6A23C)
                      : const Color(0x55C8B89A),
                ),
              ),
              child: Text(
                chips[index],
                style: TextStyle(
                  color: on ? Colors.white : const Color(0xFF4A4538),
                  fontSize: layout.fontButton,
                  fontWeight: on ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentCapsules extends StatelessWidget {
  const _RecentCapsules({required this.layout, required this.items});
  final HealingLayout layout;
  final List<MeditationFeaturedItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.sz(120),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: layout.pagePad),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: layout.cardGap),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => openMeditationFeatured(item),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                layout.sz(10),
                layout.sz(10),
                layout.sz(22),
                layout.sz(10),
              ),
              decoration: BoxDecoration(
                color: const Color(0xEEFFFFFF),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0x55C8B89A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Image.asset(
                      item.coverImageAsset,
                      width: layout.sz(84),
                      height: layout.sz(84),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: layout.cardGap),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: layout.sz(220)),
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF2C3338),
                        fontSize: layout.fontCardTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.layout,
    required this.title,
    this.showMore = true,
    this.onViewAll,
  });

  final HealingLayout layout;
  final String title;
  final bool showMore;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF2C3338);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.moduleSpace,
        layout.pagePad,
        layout.sectionTitleGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: layout.fontModuleTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showMore)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onViewAll,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.sz(4),
                  vertical: layout.sz(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '查看全部',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.72),
                        fontSize: layout.fontAssist,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: color,
                      size: layout.pt(20),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedPair extends StatelessWidget {
  const _FeaturedPair({
    required this.layout,
    required this.items,
    required this.onTap,
  });

  final HealingLayout layout;
  final List<MeditationContentItem> items;
  final ValueChanged<MeditationContentItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.pagePad),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: layout.cardGap),
            Expanded(
              child: _TallContentCard(
                layout: layout,
                item: items[i],
                onTap: () => onTap(items[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TallContentCard extends StatelessWidget {
  const _TallContentCard({
    required this.layout,
    required this.item,
    required this.onTap,
  });

  final HealingLayout layout;
  final MeditationContentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(layout.radiusContent),
        child: SizedBox(
          height: layout.pt(180),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(item.coverImageAsset, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xB3141A12)],
                    stops: [.38, 1],
                  ),
                ),
              ),
              Positioned(
                left: layout.sz(16),
                right: layout.sz(12),
                bottom: layout.sz(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: layout.fontCardTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: layout.sz(6)),
                    Text(
                      '${item.practiceMinutes} 分钟',
                      style: TextStyle(
                        color: const Color(0xE6FFF8EC),
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
  }
}

class _HorizontalCards extends StatelessWidget {
  const _HorizontalCards({
    required this.layout,
    required this.items,
    required this.onTap,
  });

  final HealingLayout layout;
  final List<MeditationContentItem> items;
  final ValueChanged<MeditationContentItem> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.pt(168),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: layout.pagePad),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: layout.cardGap),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onTap(item),
            child: SizedBox(
              width: layout.pt(140),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(layout.radiusContent),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(item.coverImageAsset, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xB3141A12)],
                          stops: [.38, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: layout.sz(16),
                      right: layout.sz(12),
                      bottom: layout.sz(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: layout.fontCardTitle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: layout.sz(6)),
                          Text(
                            '${item.practiceMinutes} 分钟',
                            style: TextStyle(
                              color: const Color(0xE6FFF8EC),
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.moduleSpace,
        layout.pagePad,
        0,
      ),
      child: Container(
        padding: EdgeInsets.all(layout.sz(26)),
        decoration: BoxDecoration(
          color: const Color(0xEEFFFFFF),
          borderRadius: BorderRadius.circular(layout.radiusMember),
          border: Border.all(color: const Color(0x55C8B89A)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '正念小提示',
                    style: TextStyle(
                      color: const Color(0xFF2C3338),
                      fontSize: layout.fontSecondaryTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: layout.sz(8)),
                  Text(
                    '不必追求空白大脑，觉察到分心，再轻轻回来就好。',
                    style: TextStyle(
                      color: const Color(0xFF6B634F),
                      fontSize: layout.fontAssist,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF6B634F),
              size: layout.pt(20),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberBanner extends StatelessWidget {
  const _MemberBanner({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.moduleSpace,
        layout.pagePad,
        layout.pt(8),
      ),
      child: Container(
        padding: EdgeInsets.all(layout.sz(28)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(layout.radiusMember),
          gradient: const LinearGradient(
            colors: [Color(0xFFE6A23C), Color(0xFFD4843A)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '解锁完整冥想库',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: layout.fontSecondaryTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: layout.sz(8)),
                  Text(
                    '减压、情绪急救与多日专题一次开通',
                    style: TextStyle(
                      color: const Color(0xF2FFFFFF),
                      fontSize: layout.fontAssist,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8A5A18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              child: Text(
                '了解会员',
                style: TextStyle(
                  fontSize: layout.fontButton,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
