import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/ui/ui.dart';
import '../../l10n/app_localizations.dart';
import 'catalog_controller.dart';

class CatalogRefreshPage extends GetView<CatalogController> {
  const CatalogRefreshPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = FTheme.of(context);

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.catalogRefreshTitle),
        prefixes: [
          FHeaderAction.back(onPress: Get.back),
        ],
      ),
      child: Obx(() {
        final count = controller.refreshCount.value;
        return AppPullRefresh(
          onRefresh: controller.pullRefresh,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.spaceMd,
                  tokens.spaceSm,
                  tokens.spaceMd,
                  tokens.spaceMd,
                ),
                child: Text(
                  l10n.catalogRefreshHint,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FTileGroup(
                children: [
                  for (var i = 1; i <= count; i++)
                    FTile(title: Text(l10n.catalogRefreshItem(i))),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
