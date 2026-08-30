# healing_tabs 复盘补缺 — 首个端到端实例

> 产品：云遥（Bundle `com.nightelf.yunyao`）· handoff slug：`healing_tabs`  
> 路径：`App/apps/healing_tabs` · Gate 全 PASS · TestFlight build 2（麦克风 plist 修复后）

---

## 已跑通的路径

| 阶段 | 状态 | 关键产出 |
|------|------|----------|
| PRD | PASS | `docs/product/2026-08-28-松息/` |
| IP | PASS | `output/brand-ip/healing_tabs/` |
| 原型 | PASS | `docs/prototype/` + `06_asset_ui` |
| 脚手架 | PASS | `App/apps/healing_tabs` |
| 功能 | PASS | 播放器/睡眠/呼吸/声景库/设置 |
| QA | PASS | `qa-report.md` |
| App Store | PASS | `app-store-submission.md`、本地 IPA、TestFlight 上传脚本 |

**MVP loop（实测）**：声景库 → 播放 → 睡眠会话 → 报告；收藏、服务器音频同步、切后台暂停。

---

## 摩擦清单 → 补缺动作

| # | 摩擦 | 严重度 | 已修 | 待晋升 Playbook |
|---|------|--------|------|-----------------|
| 1 | 系统 Ruby 2.6 vs mise Ruby 3.3，`bundle install` 编译 json 失败 | 高 | `.ruby-version` + `ensure_ruby` | **app_store:ruby_mise_for_fastlane**（第 2 次） |
| 2 | macOS Bash 3.2 将 `$LANE（构建 + 上传）` 误解析为 `${LANE+...}` | 中 | `${LANE}` 花括号 | **app_store:bash32_var_braces**（第 1 次） |
| 3 | fastlane 子进程找不到 mise 的 `pod` | 高 | `ensure_pod_in_path!` | 同上 #1 |
| 4 | `MATCH_GIT_URL` 指向代码仓 + SSH 无权限 | 高 | 默认 `SKIP_MATCH=true` | **app_store:skip_match_local_signing**（第 2 次） |
| 5 | Bundle ID 三处不一致（handoff / pbxproj / .env） | 高 | 统一 `com.nightelf.yunyao` | **scaffold:bundle_id_single_source**（第 2 次） |
| 6 | `.env` 含密钥却被 git 跟踪 | 高 | commit 时排除；**应加 .gitignore** | **scaffold:env_gitignore**（第 1 次） |
| 7 | API Key 多行写入 .env，dotenv 解析失败 | 中 | `APP_STORE_CONNECT_API_KEY_KEY_PATH` | **app_store:p8_key_path**（第 1 次） |
| 8 | ITMS-90683 缺 `NSMicrophoneUsageDescription` | 高 | Info.plist + build 2 | **app_store:audio_session_mic_plist**（第 1 次） |
| 9 | App Icon 模板占位 | 中 | `scripts/sync_app_icons.sh` | 可并入 scaffold |
| 10 | Launch Image 仍占位 | 低 | 未修 | 提审前补品牌启动图 |
| 11 | 隐私政策 URL 占位 | 中 | 文档标注 | 上线前换真实 URL |
| 12 | `handoff` 仍写 `com.healingtabs` / 产品名「疗愈」与商店「云遥」漂移 | 低 | 运营层接受 | 下一 App 在 intake 锁定展示名 |
| 13 | match 证书仓、GHA Secrets 未配置 | 中 | 本机 SKIP_MATCH 绕过 | CI 需单独 playbook |
| 14 | implementation-trace 反引号导致 validator 失败 | 低 | 已修 | 写入 features skill 注意事项 |
| 15 | 底栏溢出多轮修复 | 中 | `fitScale` | 写入 QA skill 样例 |

---

## 推荐下一 App 开工检查表（5 分钟）

- [ ] Apple Developer：Team ID、Bundle ID、App Store Connect App 已建
- [ ] `instance.config.yaml` → `apply_instance_config.rb`（或手填 `.env.example`）
- [ ] `.env` 在 `.gitignore`；API Key 用 `KEY_PATH` 指向 `.p8`
- [ ] `mise install` + `.ruby-version` 3.3.6
- [ ] `SKIP_MATCH=true` 直到证书仓就绪
- [ ] 音频 App：`NSMicrophoneUsageDescription` + `UIBackgroundModes: audio`
- [ ] `handoff-manifest.json` 从模板复制，每 Gate 后 `validate_handoff.py`

---

## defer 项（不阻塞 Gate，但路线图要有）

| 项 | 计划 |
|----|------|
| P0-05 轻唤醒 | MVP+1，本地通知 |
| P0-08 订阅 StoreKit | MVP+1 |
| 离线下载队列 UI | MVP+1 |
| 锁屏 Now Playing | MVP+1 |
| Launch Screen 品牌图 | 提审前 |
| 真机 Profile 帧率 | 提审前补测 |

---

## 建议立即晋升的 Playbook（count 即将 ≥3）

1. **iOS 本机签名 + TestFlight 一键上传**（#1+#3+#4+#7 合并）  
   目标：`07_AppStore/release-to-app-store/references/local-testflight-upload.md`

2. **Bundle ID 单一数据源**（#5+#6）  
   目标：`04_Dev/create-flutter-app/references/instance-config-checklist.md`

3. **音频类 App Info.plist 合规**（#8）  
   目标：`07_AppStore/release-to-app-store/references/ios-audio-plist.md`

登记命令：

```bash
python3 08_Learn/evolve-workflow/scripts/log_repetition.py \
  --phase app_store \
  --pattern "mise Ruby + SKIP_MATCH + p8 KEY_PATH TestFlight 一键上传" \
  --context "healing_tabs 上架摩擦" \
  --product-slug healing_tabs
```

---

## 领域词汇漂移（domain-modeling 提醒）

| handoff 用语 | 商店/实机用语 | 建议 |
|--------------|---------------|------|
| 疗愈 / healing_tabs | 云遥 / com.nightelf.yunyao | intake 增加 `store_display_name` 与 `bundle_id` 字段，与 `app_name` 分离 |
| 松息 PRD | healing_tabs 实现 | PRD 产品名可与商店名不同，但须在 assumptions.md 记录 |

更新 `output/brand-ip/healing_tabs/CONTEXT.md` 时区分 **slug**（工程）与 **store listing**（商店）。
