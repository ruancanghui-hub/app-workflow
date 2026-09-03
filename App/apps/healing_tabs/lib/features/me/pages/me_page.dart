import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/healing_layout.dart';
import '../../../domain/models/local_account.dart';
import '../../../domain/repositories/identity_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/sound_repository.dart';
import '../../navigation/app_navigation.dart';
import '../../sound_catalog/widgets/sound_library_sheet.dart';
import '../../tabs/device/device_content_catalog.dart';
import '../me_content_catalog.dart';

/// Soft light Me page — typography/spacing from `docs/字号排板.md`.
abstract final class _MeTone {
  static const bgTop = Color(0xFFEAF2FF);
  static const bgMid = Color(0xFFF5F8FC);
  static const bgBottom = Color(0xFFF8FAFD);
  /// 主文本 #1A1A1A
  static const ink = Color(0xFF1A1A1A);
  /// 次要辅助文本 #707070
  static const muted = Color(0xFF707070);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE6EBF5);
  static const accent = Color(0xFF6B8CF5);
  static const green = Color(0xFF4F9E63);
  static const purple = Color(0xFF8B7CF0);
  static const blue = Color(0xFF5B8DEF);
  static const ring = Color(0xFF4CAF7A);
}

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  LocalAccount? _account;
  MeUsageSummary? _summary;
  var _notify = false;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final identity = Get.find<IdentityRepository>();
    final settings = Get.find<SettingsRepository>();
    final sounds = Get.find<SoundRepository>();
    final account = await identity.ensureLocalAccount();
    final favorites = await sounds.listFavorites();
    final notify = await settings.notificationsEnabled();
    if (!mounted) return;
    setState(() {
      _account = account;
      _summary = MeContentCatalog.usageSummary(favoriteCount: favorites.length);
      _notify = notify;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layout = HealingLayout(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _MeTone.bgTop,
                      _MeTone.bgMid,
                      _MeTone.bgBottom,
                    ],
                  ),
                ),
              ),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: _MeTone.accent),
                )
              else
                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _TopBar(layout: layout)),
                      SliverToBoxAdapter(
                        child: _IdentityCard(
                          layout: layout,
                          account: _account!,
                          onEditName: _editName,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: layout.cardGap),
                      ),
                      SliverToBoxAdapter(
                        child: _UsageRow(layout: layout, summary: _summary!),
                      ),
                      SliverToBoxAdapter(
                        child: _SectionTitle(layout: layout, title: '内容资产'),
                      ),
                      SliverToBoxAdapter(
                        child: _AssetTiles(
                          layout: layout,
                          favoriteCount: _summary!.favoriteCount,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _SectionTitle(layout: layout, title: '播放历史'),
                      ),
                      SliverToBoxAdapter(child: _HistoryList(layout: layout)),
                      SliverToBoxAdapter(
                        child: _SectionTitle(layout: layout, title: '设备'),
                      ),
                      SliverToBoxAdapter(child: _RingEntry(layout: layout)),
                      SliverToBoxAdapter(
                        child: _SectionTitle(layout: layout, title: '设置与合规'),
                      ),
                      SliverToBoxAdapter(
                        child: _SettingsBlock(
                          layout: layout,
                          notify: _notify,
                          onNotifyChanged: (v) async {
                            await Get.find<SettingsRepository>()
                                .setNotificationsEnabled(v);
                            if (mounted) setState(() => _notify = v);
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: layout.moduleSpace),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _account?.displayName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2028),
        title: const Text('修改昵称', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 12,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '怎么称呼你',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final next = await Get.find<IdentityRepository>().updateDisplayName(result);
    if (mounted) setState(() => _account = next);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.pt(8),
        layout.pagePad,
        layout.pt(24),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: layout.pt(8)),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _MeTone.ink,
                size: layout.pt(20),
              ),
            ),
          ),
          Text(
            '我的',
            style: TextStyle(
              color: _MeTone.ink,
              fontSize: layout.fontPageTitle,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.layout,
    required this.account,
    required this.onEditName,
  });

  final HealingLayout layout;
  final LocalAccount account;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.pagePadding,
      child: _SurfaceCard(
        layout: layout,
        padding: EdgeInsets.all(layout.pt(16)),
        child: Row(
          children: [
            Image.asset(
              'assets/images/me/status/profile_avatar.png',
              width: layout.pt(56),
              height: layout.pt(56),
            ),
            SizedBox(width: layout.cardGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onEditName,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _MeTone.ink,
                              fontSize: layout.fontSecondaryTitle,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(width: layout.pt(6)),
                        Icon(
                          Icons.edit_outlined,
                          color: _MeTone.muted,
                          size: layout.pt(16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: layout.pt(6)),
                  Text(
                    '本机云遥账号',
                    style: TextStyle(
                      color: _MeTone.green,
                      fontSize: layout.fontAssist,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: layout.pt(6)),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('绑定手机即将开放，换机同步可稍后设置')),
                      );
                    },
                    child: Text(
                      '绑定手机，换机可同步 ›',
                      style: TextStyle(
                        color: _MeTone.muted,
                        fontSize: layout.fontAssist,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.layout, required this.summary});
  final HealingLayout layout;
  final MeUsageSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.pagePadding,
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              layout: layout,
              icon: Icons.calendar_today_rounded,
              iconColor: _MeTone.blue,
              label: '连续使用',
              value: '${summary.streakDays} 天',
            ),
          ),
          SizedBox(width: layout.cardGap),
          Expanded(
            child: _StatChip(
              layout: layout,
              icon: Icons.favorite_rounded,
              iconColor: _MeTone.blue,
              label: '收藏',
              value: '${summary.favoriteCount}',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.layout,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final HealingLayout layout;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      layout: layout,
      padding: EdgeInsets.all(layout.pt(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: layout.pt(16)),
              SizedBox(width: layout.pt(6)),
              Text(
                label,
                style: TextStyle(
                  color: _MeTone.muted,
                  fontSize: layout.fontAssist,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: layout.pt(8)),
          Text(
            value,
            style: TextStyle(
              color: _MeTone.ink,
              fontSize: layout.fontModuleTitle,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.layout, required this.title});
  final HealingLayout layout;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.pagePad,
        layout.moduleSpace,
        layout.pagePad,
        layout.sectionTitleGap,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: _MeTone.ink,
          fontSize: layout.fontModuleTitle,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _AssetTiles extends StatelessWidget {
  const _AssetTiles({required this.layout, required this.favoriteCount});

  final HealingLayout layout;
  final int favoriteCount;

  @override
  Widget build(BuildContext context) {
    return _ListGroup(
      layout: layout,
      children: [
        _MeListRow(
          layout: layout,
          icon: Icons.favorite_rounded,
          iconColor: _MeTone.purple,
          iconBg: const Color(0xFFF0ECFF),
          title: '我的收藏',
          subtitle: favoriteCount == 0 ? '还没有收藏' : '已收藏 $favoriteCount 个声景',
          onTap: () => showSoundLibrarySheet(context),
        ),
        _MeListRow(
          layout: layout,
          icon: Icons.schedule_rounded,
          iconColor: _MeTone.blue,
          iconBg: const Color(0xFFEAF1FF),
          title: '最近练习',
          subtitle: MeContentCatalog.usageSummary(
            favoriteCount: favoriteCount,
          ).lastActivityLabel,
          onTap: () {},
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    return _ListGroup(
      layout: layout,
      children: [
        for (final item in MeContentCatalog.history)
          _MeListRow(
            layout: layout,
            icon: Icons.play_arrow_rounded,
            iconColor: _MeTone.blue,
            iconBg: const Color(0xFFEAF1FF),
            title: item.title,
            subtitle: '${item.subtitle} · ${item.playedAtLabel}',
            onTap: () {},
          ),
      ],
    );
  }
}

class _RingEntry extends StatelessWidget {
  const _RingEntry({required this.layout});
  final HealingLayout layout;

  @override
  Widget build(BuildContext context) {
    final device = DeviceContentCatalog.pairedSnapshot.device;
    final label = device.isPaired
        ? '已连接 · 电量 ${device.batteryPercent}%'
        : '未配对';
    return _ListGroup(
      layout: layout,
      children: [
        _MeListRow(
          layout: layout,
          icon: Icons.radio_button_unchecked_rounded,
          iconColor: _MeTone.ring,
          iconBg: const Color(0xFFE6F6EC),
          title: '我的戒指',
          subtitle: label,
          onTap: () {
            Get.back();
            openDeviceTab();
          },
        ),
      ],
    );
  }
}

class _SettingsBlock extends StatelessWidget {
  const _SettingsBlock({
    required this.layout,
    required this.notify,
    required this.onNotifyChanged,
  });

  final HealingLayout layout;
  final bool notify;
  final ValueChanged<bool> onNotifyChanged;

  @override
  Widget build(BuildContext context) {
    return _ListGroup(
      layout: layout,
      children: [
        _MeListRow(
          layout: layout,
          icon: Icons.notifications_none_rounded,
          iconColor: _MeTone.blue,
          iconBg: const Color(0xFFEAF1FF),
          title: '通知提醒',
          subtitle: '关闭后仍可使用伴睡，轻唤醒将降级',
          trailing: Switch.adaptive(
            value: notify,
            activeThumbColor: Colors.white,
            activeTrackColor: _MeTone.accent,
            onChanged: onNotifyChanged,
          ),
        ),
        _MeListRow(
          layout: layout,
          icon: Icons.privacy_tip_outlined,
          iconColor: _MeTone.blue,
          iconBg: const Color(0xFFEAF1FF),
          title: '隐私说明',
          subtitle: '数据默认保存在本机；非医疗诊断产品。',
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: const Color(0xFF1A2028),
                title: const Text(
                  '隐私说明',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  '云遥使用本机云遥账号保存偏好、收藏与睡眠会话。'
                  '体征与音频数据不会用于医疗诊断。',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('知道了'),
                  ),
                ],
              ),
            );
          },
        ),
        _MeListRow(
          layout: layout,
          icon: Icons.info_outline_rounded,
          iconColor: _MeTone.blue,
          iconBg: const Color(0xFFEAF1FF),
          title: '关于云遥',
          subtitle: '版本 0.1.0',
          showChevron: false,
        ),
      ],
    );
  }
}

/// White card — content cover / banner radius 16pt.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.layout,
    required this.child,
    this.padding,
  });

  final HealingLayout layout;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _MeTone.card,
        borderRadius: BorderRadius.circular(layout.radiusContent),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A2B4A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Grouped list: one bordered surface, rows separated by inset dividers.
class _ListGroup extends StatelessWidget {
  const _ListGroup({required this.layout, required this.children});

  final HealingLayout layout;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final iconSlot = layout.pt(40) + layout.pt(16) + layout.pt(12);
    return Padding(
      padding: layout.pagePadding,
      child: _SurfaceCard(
        layout: layout,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: EdgeInsets.only(left: iconSlot),
                  child: const Divider(
                    height: 1,
                    thickness: 1,
                    color: _MeTone.divider,
                  ),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _MeListRow extends StatelessWidget {
  const _MeListRow({
    required this.layout,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.showChevron = true,
  });

  final HealingLayout layout;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: layout.pt(16),
        vertical: layout.pt(14),
      ),
      child: Row(
        children: [
          Container(
            width: layout.pt(40),
            height: layout.pt(40),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(layout.radiusDepart),
            ),
            child: Icon(icon, color: iconColor, size: layout.pt(20)),
          ),
          SizedBox(width: layout.pt(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _MeTone.ink,
                    fontSize: layout.fontCardTitle,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: layout.pt(4)),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _MeTone.muted,
                    fontSize: layout.fontAssist,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: _MeTone.muted,
              size: layout.pt(20),
            ),
        ],
      ),
    );

    if (onTap == null && trailing != null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
