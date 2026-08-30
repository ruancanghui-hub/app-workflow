# App Store Submission — healing_tabs

## 元数据

| 字段 | 值 |
|------|-----|
| App 名称 | 疗愈 |
| 副标题 | 声景伴睡，温柔入眠 |
| Bundle ID | `com.healingtabs.HealingTabs` |
| SKU | `healing_tabs_v1` |
| 主要类别 | 健康健美 |
| 次要类别 | 生活方式 |
| 年龄分级 | 17+（无医疗内容；无 unrestricted web） |
| 版权 | © 2026 Healing Tabs |

## 版本

| 字段 | 值 |
|------|-----|
| Marketing Version | 0.1.0 |
| Build Number | 1 |
| 最低 iOS | 16.0 |

**递增规则**：每次提审 `Build Number` +1；对外功能里程碑 bump `Marketing Version`（semver）。

## 文案

**推广文本**（170 字内）:

用原创自然声景与睡前仪式，帮助你在夜晚更快放松、安心入睡。选声景、开睡眠会话、查看基础报告——全程 wellness 表述，非医疗诊断。

**描述**:

疗愈是一款面向 18+ 成人的身心放松 App，帮助你用声音与简单仪式改善入睡体验。

核心功能：
• 自然声景播放：本地与服务器音频，支持收藏与倒计时
• 睡眠会话：记录在床时长，生成基础睡眠报告
• 呼吸引导：4-7-8 节奏练习，睡前快速安定
• 冥想入口：引导式放松练习（MVP 骨架）

无需注册即可使用核心功能（游客模式）。数据默认保存在本机。

本产品不提供医疗诊断、失眠治疗或临床睡眠分期。如有持续睡眠问题，请咨询专业医生。

**关键词**:

睡眠,白噪音,冥想,放松,声景,呼吸,助眠,减压,正念,自然音

## 审核信息

- **联系邮箱**: developer@example.com（提审前替换为真实支持邮箱）
- **联系电话**: +86-000-0000-0000（提审前替换）
- **演示账号**: 无需登录 / N/A — 打开 App 即游客模式，全部 MVP 功能可直接体验
- **审核备注**:

```
【测试步骤】
1. 冷启动 → 首页 Tab
2. 点击「声景库」或声音 Tab → 选择任一声景 → 播放
3. 睡眠 Tab → 开始睡眠会话 → 等待数秒 → 结束 → 查看报告
4. 冥想 Tab → 呼吸引导 → 完成一轮
5. 设置（首页齿轮）→ 查看隐私说明、刷新服务器音频

【账号】
无需演示账号。游客模式默认开启，无注册/登录墙。

【非医疗声明】
本 App 为 wellness / 放松辅助工具，不诊断、不治疗失眠或任何疾病。
睡眠报告仅展示会话时长与主观评分，无深浅睡分期或临床指标。

【已知限制（引用 qa-report defer）】
- 轻唤醒（本地闹钟）未在 MVP 实现，将于下一版本提供
- 订阅付费墙未接入 StoreKit，当前全部声景可免费体验
- 无锁屏 Now Playing 控件
- 音频服务器使用 HTTP（已在 ATS 配置例外域名 139.199.211.157）

【后台音频】
播放中切后台会暂停并提示「继续播放」，符合 MVP 生命周期策略。
UIBackgroundModes: audio 已声明，伴睡可后台续播。

【加密】
仅使用标准 HTTPS/TLS 与 Apple 系统 API，无自定义加密 → Export Compliance: No
```

## TestFlight

| 阶段 | Build | 日期 | 结果 |
|------|-------|------|------|
| 内部测试 | 1 (0.1.0+1) | 2026-08-30 | **IPA 已本地构建** — `build/ios/ipa/*.ipa`，待 Transporter 上传 |
| 外部测试 | — | — | N/A（首发仅内部） |

### 一键上传（推荐）

```bash
cd App/apps/healing_tabs

# 1. 配置凭据（仅首次）
cp .env.example .env   # 若尚未配置
# 编辑 .env：APPLE_TEAM_ID、App Store Connect API Key（.p8）

# 2. 首次签名（match 证书仓库）
cd ios && bundle exec fastlane match appstore

# 3. 一键：同步图标 → 构建 prod IPA → 上传 TestFlight
cd ..
./scripts/upload_app_store.sh

# 或上传到 App Store（不自动提审）
./scripts/upload_app_store.sh --release
```

图标源目录：`assets/images/icons/`（修改后重新运行脚本即可同步）。

若本机已有 Distribution 证书：`SKIP_MATCH=true ./scripts/upload_app_store.sh`

### Prod 构建命令（仅构建，不上传）

```bash
cd App/apps/healing_tabs

# 一次性：配置签名团队
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
# 编辑 DEVELOPMENT_TEAM=<你的 Team ID>

# 构建 IPA
flutter build ipa \
  --flavor prod \
  --dart-define=APP_VARIANT=prod \
  --dart-define-from-file=dart_defines.prod.json

# 或通过 Xcode：打开 ios/Runner.xcworkspace → scheme prod → Archive → Distribute
```

**预检清单**：见 `07_AppStore/release-to-app-store/references/ios-release-checklist.md`

**本地构建结果（2026-08-30）**：
- ✓ Archive + IPA 成功（`com.healingtabs.HealingTabs` 0.1.0+1）
- ✓ App Icon 已从 `assets/images/icons` 同步至 Xcode Asset Catalog

## 商店素材

截图归档：`screenshots/`（6.7" 与 6.5" 各 ≥3 张主路径）

| 序号 | 场景 | 建议设备 |
|------|------|----------|
| 1 | 首页 + 四 Tab | iPhone 15 Pro Max (6.7") |
| 2 | 声景播放中 | 同上 |
| 3 | 睡眠会话 / 报告 | 同上 |
| 4 | 呼吸引导 | iPhone 11 Pro Max (6.5") |
| 5 | 声景库列表 | 同上 |
| 6 | 设置 / 隐私说明 | 同上 |

设计参考（非最终截图）：`output/brand-ip/healing_tabs/04-core-tab-ui/`

## 提审状态

- **submission_status**: testflight
- **submitted_at**: —
- **App Store Connect URL**: （创建 App 记录后填入）

## Gate

**app_store_gate**: PASS

PASS 定义：提审包文档齐全、隐私问卷完成、prod 构建命令与素材清单就绪；IPA 待团队签名上传 TestFlight。
