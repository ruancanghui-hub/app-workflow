# 模拟器权限与系统能力

## 通知

`xcrun simctl privacy` 不支持通知权限。用 [applesimutils](https://github.com/wix/AppleSimulatorUtils)：

```bash
brew tap wix/brew            # 需用户同意信任第三方 tap
brew install applesimutils
applesimutils --byId <udid> --bundle <bundle_id> --setPermissions notifications=YES
sleep 8                      # 该命令会重启 SpringBoard，等它恢复
```

规则：

- 在 `flutter drive` **之前**执行一次；不要在 drive 过程中或循环里执行，否则 SpringBoard 反复重启，App 启动失败（`Failed to launch`）。
- `flutter drive` 重新安装 App 可能清掉通知授权：每轮 drive 前执行一次即可。
- 未授权时 `pendingNotificationRequests()` 返回 0，这不是代码缺陷。探针应打印 `planned` 与 `pending` 两个数，用 planned>0 且 pending==0 识别“未授权”。
- 没装 applesimutils：通知项记为“仅验证排程逻辑（planned）”，报告里标注。

## 相册

```bash
xcrun simctl privacy <udid> grant  photos-add <bundle_id>   # 授权轮
xcrun simctl privacy <udid> revoke photos-add <bundle_id>   # 拒绝轮
```

- 用 dart-define 告诉探针本轮期望：`--dart-define=QA_ALBUM=granted|denied`。
- 拒绝轮期望 App 给出“去设置开启”的降级结果，不能崩溃或无提示。
- 首次安装前执行 privacy 可能失败（App 未安装）：先装一次再授权，或忽略首轮失败。

## 其它

| 能力 | 模拟器 | 处理 |
|---|---|---|
| StoreKit 购买 | 无沙盒账号 | 测“商店不可用”降级：按钮不卡忙碌态，超时内给出提示 |
| 系统分享面板 | 可弹出，无法选择微信 | 只验证调用不抛错；真机手动验收 |
| 推送弹出与点击直达 | 本地通知可排程 | 点击直达放 L3 手动清单 |
| profile / release 模式 | 不支持 | 帧数据只作上限参考，结论以真机为准 |
| 网络断开 | 无系统开关 | 在 L1 用 fake 端口模拟（offline / timeout） |

## 查找设备

```bash
xcrun simctl list devices booted --json
xcrun devicectl list devices --json-output /tmp/devices.json
flutter devices
```

`detect_test_targets.py` 已封装上面两条 xcrun 调用。
