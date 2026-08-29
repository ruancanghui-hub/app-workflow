// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get homeTitle => '首页';

  @override
  String get homeHello => '你好，世界！';

  @override
  String homeVariant(String variant) {
    return '构建变体：$variant';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLogEvent => '打一条行为埋点';

  @override
  String get settingsFeatureFlag => '功能开关：demo_flag';

  @override
  String get settingsTestCrash => '触发测试异常（仅 dev）';

  @override
  String get settingsHeartbeat => '发送运营台心跳';

  @override
  String get settingsLastEvent => '最近事件';
}
