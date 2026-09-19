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
  String get homeOpenCatalog => '打开能力目录';

  @override
  String get homeOpenSettings => '打开设置';

  @override
  String get homeDiagnosticsHint => '连续点击标题 7 次可进入诊断页（正式环境隐藏入口）。';

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

  @override
  String get catalogTitle => '能力目录';

  @override
  String get catalogIntro => '现场演示 App* 控件、动效、行为埋点与帧卡顿监测。';

  @override
  String get catalogSectionSplash => '启动与引导';

  @override
  String get catalogPreviewSplash => '预览启动品牌页';

  @override
  String get catalogPreviewOnboarding => '预览引导页';

  @override
  String get catalogResetOnboarding => '重置引导标记';

  @override
  String get catalogResetOnboardingDone => '下次冷启动将再次进入引导页';

  @override
  String get catalogSectionRating => '评分与反馈';

  @override
  String get catalogShowRating => '弹出评分提示';

  @override
  String get catalogShowRatingHint => '好评→商店，差评→反馈，再用用看→关闭';

  @override
  String get catalogOpenFeedback => '打开反馈表单';

  @override
  String get ratingTitle => '给我们评分';

  @override
  String get ratingMessage => '您的鼓励能让更多人发现这款应用';

  @override
  String get ratingPositive => '不错！去鼓励一下';

  @override
  String get ratingNegative => '不能忍，要吐槽！';

  @override
  String get ratingLater => '再用用看';

  @override
  String get ratingStoreUrlMissing =>
      '未配置商店链接（在 instance.config.yaml 的 store.* 填写）';

  @override
  String get feedbackTitle => '用户反馈';

  @override
  String get feedbackHint => '告诉我们哪里不好。只会打提交事件，正文留在本机。';

  @override
  String get feedbackMessageLabel => '反馈内容';

  @override
  String get feedbackMessageHint => '希望我们改进什么？';

  @override
  String get feedbackSubmit => '提交';

  @override
  String get feedbackSubmitted => '已记录，谢谢反馈';

  @override
  String get splashInitializing => '正在初始化…';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get onboardingSlide1Title => '扎实底座';

  @override
  String get onboardingSlide1Body => '品牌启动页、构建变体与运营端口，帮你更快打出第一包。';

  @override
  String get onboardingSlide2Title => '可复用 App* 控件';

  @override
  String get onboardingSlide2Body => '按钮、弹框、Toast、骨架与转场都在 core/ui。';

  @override
  String get onboardingSlide3Title => '看得见的运营能力';

  @override
  String get onboardingSlide3Body => '类型化埋点、卡顿采样与诊断入口，支撑健康发布。';

  @override
  String get onboardingSlide4Title => '换成你的品牌';

  @override
  String get onboardingSlide4Body =>
      '替换 Logo、slogan、版权；大版本更新时 bump onboarding_version。';

  @override
  String get catalogSectionButtons => '按钮';

  @override
  String get catalogButtonsHint => 'AppButton 各变体与 loading 状态。';

  @override
  String get catalogSectionDialogs => '对话框';

  @override
  String get catalogDialogConfirm => '确认对话框';

  @override
  String get catalogDialogAlert => '提示对话框';

  @override
  String get catalogSectionFeedback => '反馈';

  @override
  String get catalogFeedbackOverlay => '全屏加载遮罩';

  @override
  String get catalogSectionPlaceholders => '占位';

  @override
  String get catalogEmptyTitle => '暂无内容';

  @override
  String get catalogEmptyDescription => '空状态使用 AppEmpty。';

  @override
  String get catalogSectionMotion => '动效';

  @override
  String get catalogMotionAppearHint => '本卡片由 AppAppear 包裹。点击下方按钮预览页面转场。';

  @override
  String get catalogMotionSharedAxis => 'Shared axis 转场';

  @override
  String get catalogMotionFadeThrough => 'Fade through 转场';

  @override
  String get catalogMotionFadeScale => 'Fade scale 转场';

  @override
  String get catalogSectionLoadingMotion => '加载视图';

  @override
  String get catalogMotionLoadingHint => '转圈、线性进度，以及骨架到内容的 fade-through。';

  @override
  String get catalogMotionRunProgress => '播放确定进度';

  @override
  String get catalogMotionReveal => '切换已加载内容';

  @override
  String get catalogMotionLoadedContent => '内容已就绪。这块替换了骨架屏。';

  @override
  String get catalogSectionPullRefresh => '下拉刷新';

  @override
  String get catalogMotionPullRefresh => '打开下拉刷新页';

  @override
  String get catalogMotionPullRefreshHint => '全屏列表，可下拉。';

  @override
  String get catalogRefreshTitle => '下拉刷新';

  @override
  String get catalogRefreshHint => '下拉新增一行。指示器为 FCircularProgress.loader。';

  @override
  String catalogRefreshItem(int index) {
    return '条目 $index';
  }

  @override
  String get catalogSectionAccordion => '列表展开';

  @override
  String get catalogAccordionHint => 'FAccordion 带动画高度与箭头旋转。';

  @override
  String get catalogAccordionItem1 => '这是什么？';

  @override
  String get catalogAccordionBody1 => '可点开标题，展开后显示补充说明。';

  @override
  String get catalogAccordionItem2 => '什么时候用？';

  @override
  String get catalogAccordionBody2 => 'FAQ、分组设置，或任何需要收起细节的列表。';

  @override
  String get catalogAccordionItem3 => '动画怎么做？';

  @override
  String get catalogAccordionBody3 => 'Forui 负责高度裁剪和箭头旋转。';

  @override
  String get catalogSectionUpdatePrompt => '更新提示';

  @override
  String get catalogUpdateShowSheet => '弹出更新 sheet';

  @override
  String get catalogUpdateShowBanner => '显示更新横幅';

  @override
  String get catalogUpdateDismissBanner => '关闭横幅';

  @override
  String get catalogUpdateTitle => '发现新版本';

  @override
  String get catalogUpdateVersion => '版本 1.2.0';

  @override
  String get catalogUpdateNotes => '缺陷修复，以及更完整的目录动效演示。';

  @override
  String get catalogUpdateAction => '立即更新';

  @override
  String get catalogUpdateLater => '稍后';

  @override
  String get catalogUpdateStarted => '已开始更新';

  @override
  String get catalogUpdateBannerTitle => '有新版本可用';

  @override
  String get catalogUpdateBannerSubtitle => '点 sheet 按钮可预览上滑提示框。';

  @override
  String get catalogSectionAnalytics => '行为埋点';

  @override
  String get catalogAnalyticsBackend => '埋点后端';

  @override
  String get catalogAnalyticsFire => '触发目录演示事件';

  @override
  String get catalogAnalyticsLast => '最近事件';

  @override
  String get catalogSectionMonitoring => '监测';

  @override
  String get catalogMonitoringJankCount => '近期卡顿次数';

  @override
  String get catalogMonitoringSimulate => '模拟卡顿';

  @override
  String get catalogMonitoringDiagnostics => '打开诊断页';

  @override
  String get catalogSectionMotionAssets => 'Lottie / Rive';

  @override
  String get catalogMotionAssetsTitle => '请在实例中添加资源';

  @override
  String get catalogMotionAssetsDescription =>
      '实例加入资源后使用 AppLottie.asset / AppRive.asset。模板不内置示例大文件（ADR 0005）。';
}
