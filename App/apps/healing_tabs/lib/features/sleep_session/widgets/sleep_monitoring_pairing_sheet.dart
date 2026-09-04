import 'package:flutter/material.dart';

import '../../../core/design/healing_layout.dart';
import '../../navigation/app_navigation.dart';

Future<void> showSleepMonitoringPairingSheet(BuildContext context) async {
  final layout = HealingLayout.of(context);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF121A18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(layout.radiusContent),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          layout.pagePad,
          layout.pt(20),
          layout.pagePad,
          layout.pt(28) + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '请先配对戒指',
              style: TextStyle(
                color: Colors.white,
                fontSize: layout.fontModuleTitle,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: layout.pt(10)),
            Text(
              '睡眠监测需要已连接的云遥戒指采集体征。配对后即可开始今晚监测并查看睡眠报告。',
              style: TextStyle(
                color: const Color(0xB6D1DBED),
                fontSize: layout.fontAssist,
                height: 1.4,
              ),
            ),
            SizedBox(height: layout.moduleSpace),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                openDeviceTabForPairing();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB2F2BB),
                foregroundColor: const Color(0xFF102018),
                minimumSize: Size.fromHeight(layout.pt(48)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              child: Text(
                '去配对戒指',
                style: TextStyle(
                  fontSize: layout.fontButton,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                '稍后再说',
                style: TextStyle(
                  color: const Color(0x99B2F2BB),
                  fontSize: layout.fontButton,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
