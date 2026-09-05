import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_layout.dart';
import '../../../domain/models/meditation_content.dart';
import '../../../domain/models/sleep_content.dart';
import '../../navigation/app_navigation.dart';
import '../../tabs/meditation/meditation_content_catalog.dart';
import '../../tabs/sleep/sleep_content_catalog.dart';

/// GetX arguments for [ContentCategoryListPage].
class ContentCategoryListArgs {
  const ContentCategoryListArgs({
    required this.tab,
    required this.categoryId,
  });

  /// `'sleep'` or `'meditation'`.
  final String tab;
  final String categoryId;
}

class ContentCategoryListPage extends StatelessWidget {
  const ContentCategoryListPage({super.key});

  static const _titleColor = Color(0xFF1A1A1A);
  static const _assistColor = Color(0xFF707070);

  @override
  Widget build(BuildContext context) {
    final raw = Get.arguments;
    final args = raw is ContentCategoryListArgs
        ? raw
        : const ContentCategoryListArgs(tab: 'sleep', categoryId: '');

    if (args.tab == 'sleep') {
      final category = _findSleep(args.categoryId);
      if (category == null) {
        return const _MissingCategoryScaffold();
      }
      return _CategoryGridPage(
        title: category.title,
        hint: category.hint,
        items: [
          for (final item in category.items)
            _GridItemData(
              cover: item.coverImageAsset,
              title: item.title,
              meta: '${item.practiceMinutes} 分钟 · ${category.title}',
              onTap: () => openSleepContent(item),
            ),
        ],
      );
    }

    final category = _findMeditation(args.categoryId);
    if (category == null) {
      return const _MissingCategoryScaffold();
    }
    return _CategoryGridPage(
      title: category.title,
      hint: category.hint,
      items: [
        for (final item in category.items)
          _GridItemData(
            cover: item.coverImageAsset,
            title: item.title,
            meta: '${item.practiceMinutes} 分钟 · ${category.title}',
            onTap: () => openMeditationContent(item),
          ),
      ],
    );
  }

  static SleepContentCategory? _findSleep(String id) {
    for (final c in SleepContentCatalog.categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  static MeditationContentCategory? _findMeditation(String id) {
    for (final c in MeditationContentCatalog.categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}

class _GridItemData {
  const _GridItemData({
    required this.cover,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final String cover;
  final String title;
  final String meta;
  final VoidCallback onTap;
}

class _MissingCategoryScaffold extends StatelessWidget {
  const _MissingCategoryScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ContentCategoryListPage._titleColor,
        elevation: 0,
        title: const Text('分类'),
      ),
      body: const Center(
        child: Text(
          '未找到该分类',
          style: TextStyle(color: ContentCategoryListPage._assistColor),
        ),
      ),
    );
  }
}

/// 白底双列网格：对齐参考图与 `docs/字号排板.md`。
class _CategoryGridPage extends StatelessWidget {
  const _CategoryGridPage({
    required this.title,
    required this.items,
    this.hint,
  });

  final String title;
  final String? hint;
  final List<_GridItemData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HealingLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        final topInset = MediaQuery.paddingOf(context).top;
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        final cellWidth =
            (constraints.maxWidth - layout.pagePad * 2 - layout.cardGap) / 2;
        final textBlockHeight =
            layout.pt(8) + layout.pt(18) + layout.pt(4) + layout.pt(16);
        final childAspectRatio = cellWidth / (cellWidth + textBlockHeight);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    layout.pagePad,
                    topInset + layout.pt(4),
                    layout.pagePad,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: layout.pt(44),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: Get.back,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tightFor(
                                width: layout.pt(40),
                                height: layout.pt(40),
                              ),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: layout.pt(20),
                                color: ContentCategoryListPage._titleColor,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tightFor(
                                width: layout.pt(40),
                                height: layout.pt(40),
                              ),
                              icon: Icon(
                                Icons.ios_share_rounded,
                                size: layout.pt(22),
                                color: ContentCategoryListPage._titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: layout.pt(8)),
                      Text(
                        title,
                        style: TextStyle(
                          color: ContentCategoryListPage._titleColor,
                          fontSize: layout.fontPageTitle,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      if (hint != null && hint!.isNotEmpty) ...[
                        SizedBox(height: layout.pt(8)),
                        Text(
                          hint!,
                          style: TextStyle(
                            color: ContentCategoryListPage._assistColor,
                            fontSize: layout.fontIntro,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                      SizedBox(height: layout.pt(24)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  layout.pagePad,
                  0,
                  layout.pagePad,
                  layout.pt(40) + bottomInset,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: layout.cardGap,
                    mainAxisSpacing: layout.cardGap,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return _GridCard(layout: layout, item: item);
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.layout, required this.item});

  final HealingLayout layout;
  final _GridItemData item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(layout.radiusContent),
              child: SizedBox.expand(
                child: Image.asset(item.cover, fit: BoxFit.cover),
              ),
            ),
          ),
          SizedBox(height: layout.pt(8)),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ContentCategoryListPage._titleColor,
              fontSize: layout.fontCardTitle,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
          SizedBox(height: layout.pt(4)),
          Text(
            item.meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ContentCategoryListPage._assistColor,
              fontSize: layout.fontAssist,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
