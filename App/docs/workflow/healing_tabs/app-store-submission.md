# App Store Submission — 云遥（healing_tabs）

> 版本：`1.4.0 (11)` · Apple 健康版（已移除戒指 / 蓝牙硬件）  
> 用途：打开 App Store Connect，按本页从上到下逐项粘贴。代码块里的内容可直接复制。

---

## 1. App 信息

| ASC 字段 | 填写 |
|----------|------|
| 名称 | 云遥 |
| 副标题 | 更好的睡眠，更轻的自己 |
| Bundle ID | `com.nightelf.yunyao` |
| SKU | `yunyao_v1` |
| 主要类别 | 健康健美 |
| 次要类别 | 生活方式 |
| 内容版权 | © 2026 Night Elf / 云遥 |
| 隐私政策 URL | https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html |
| 技术支持 URL | https://ruancanghui-hub.github.io/app-workflow/yunyao/ |
| 营销 URL | 留空 |

## 2. 定价与销售范围

| 项 | 填写 |
|----|------|
| 价格 | 免费 |
| App 内购买 | 无 |
| 销售地区 | 按计划选择 |

## 3. 版本

| 字段 | 值 |
|------|-----|
| 版本号 | 1.4.0 |
| Build | 11（`pubspec`：`1.4.0+11`） |
| 最低系统 | iOS 15.0 |
| 支持设备 | iPhone + iPad |

每次上传新包 Build +1。只改元数据和截图时不需要传新包。

---

## 4. 推广文本

```
自然声景、呼吸练习与冥想，陪你放松入睡。可选连接 Apple 健康，在本机查看休息摘要与心率参考；非医疗用途。
```

## 5. 描述

```
云遥是一款面向成人的放松与睡眠陪伴 App（Wellness / 生活方式），不是医疗器械，也不提供医疗服务。

核心功能：
• 自然声景：雨声、溪流、森林等白噪音，支持收藏、定时与后台播放
• 心流专注：专注倒计时搭配自然声景
• 呼吸练习：4-7-8 节奏引导，可配自然之声与时长
• 冥想：日间自然声景与放松练习
• 休息（可选 Apple 健康）：授权后，在本机查看 Apple 健康中的休息时长、睡眠阶段与心率参考曲线；没有数据时显示空状态
• 开屏广告：Google AdMob（首次需同意隐私政策）

关于 Apple 健康：
• 只读取，不写入
• 数据只在本机展示，不上传到我们的服务器，不用于广告
• 不授权也能使用全部声景、专注、呼吸与冥想功能
• 睡眠数据通常来自 Apple Watch 或 iPhone 的睡眠记录

无需注册登录。可在「我的」中删除本机数据。

重要声明：云遥仅供放松参考，不用于医疗诊断、治疗或疾病管理。如有健康问题，请咨询专业医生。

隐私政策：https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html
用户协议：https://ruancanghui-hub.github.io/app-workflow/yunyao/terms.html
```

## 6. 关键词

```
睡眠,白噪音,冥想,放松,声景,呼吸,助眠,减压,专注,Apple健康
```

文案、关键词、截图里都不要出现：戒指、智能戒指、穿戴设备、配对、蓝牙、监测、诊断、治疗。

---

## 7. 截图

### 必传尺寸

| 设备组 | 尺寸（竖屏） | 张数 |
|--------|--------------|------|
| iPhone 6.9" | 1320×2868 或 1290×2796 | 3–10 |
| iPhone 6.5"（ASC 要求时） | 1284×2778 或 1242×2688 | 3–10 |
| iPad 13" | 2064×2752 或 2048×2732 | 3–10（支持 iPad，必传） |

### 截图顺序（iPhone、iPad 各一套）

| # | 画面 | 宣传标题 |
|---|------|----------|
| 1 | 首页场景 + 睡前放松 / 心流专注 / 呼吸练习 | 在自然中，找回内心的平静 |
| 2 | 睡眠 Tab 声景列表或播放器 | 自然声景 · 沉浸助眠 |
| 3 | 呼吸练习页 | 4-7-8 呼吸 · 慢下来 |
| 4 | 冥想 Tab | 冥想减压 · 找回平静 |
| 5 | 休息 Tab「连接 Apple 健康」卡片或休息摘要 | 连接 Apple 健康 · 本地休息摘要 |
| 6 | 睡眠报告 / 心率参考页（有真实数据才用） | 休息与心率参考 · 非医疗用途 |

### 截图要求

- 必须是 `1.4.0 (11)` 的真实界面，底栏第 4 个 Tab 显示「休息」
- 不出现戒指实物图，也不出现「智能戒指联动」「配对戒指」等文字
- 宣传图底部图标用「自然声景 / 深度助眠 / 冥想减压 / Apple 健康」
- 不放假的睡眠阶段或评分；没有数据时用「连接 Apple 健康」卡片那张
- 有 App 预览视频的话，同样不能出现戒指画面

---

## 8. App 隐私

| 数据类型 | 是否勾选 | 用途 | 关联身份 | 用于追踪 |
|----------|----------|------|----------|----------|
| 健康与健身 | 不勾选（HealthKit 只在本机展示，不传出设备） | — | — | — |
| 产品交互 | 勾选（同意后，Firebase Analytics） | 分析 | 否 | 否 |
| 崩溃数据 / 性能数据 | 勾选（同意后，Crashlytics） | App 功能 | 否 | 否 |
| 设备 ID | 勾选（同意后，AdMob） | 第三方广告 | 否 | 用户允许 ATT 时为「是」 |

第三方：Google Firebase、Google AdMob。不出售用户数据。详细依据见 [`privacy-questionnaire.md`](./privacy-questionnaire.md)。

## 9. 年龄分级与合规

| 项 | 填写 |
|----|------|
| 年龄分级 | 17+（含广告，面向成人） |
| 医疗 / 治疗信息 | 无 |
| 出口合规 | 仅使用豁免加密（`ITSAppUsesNonExemptEncryption = false`） |
| HealthKit | 已开启能力，只读 |

---

## 10. App 审核信息

| 字段 | 填写 |
|------|------|
| 需要登录 | 否 |
| 演示账号 | 留空 |
| 联系人 | 真实姓名 |
| 电话 | 真实可接通电话（含国家码） |
| 邮箱 | 真实邮箱 |
| 附件 / 视频 | 不需要；旧的戒指演示视频链接请删除 |

### 审核备注

```
No account is required.

This version (1.4.0) has NO third-party hardware and NO Bluetooth accessory. The previous smart ring feature has been completely removed from the app and from all metadata.

How to test:
1. Launch the app and accept the Privacy Policy to enter Home.
2. Home: tap "睡前放松", "心流专注" or "呼吸练习" to start audio / focus / breathing.
3. "睡眠" and "冥想" tabs: play any nature sound; background audio and lock-screen controls are supported.
4. "休息" (Rest) tab (4th tab): tap "连接 Apple 健康" (Connect Apple Health) and allow read access in the system sheet.
   - The app only READS sleep analysis and heart rate from Apple Health.
   - Data is displayed locally only; it is not uploaded and not used for advertising.
   - If the review device has no Health sleep data (e.g. no Apple Watch), the tab shows an empty state. This is expected.
   - Apple Health on iPad requires iPadOS 17 or later.
5. "我的" (Me): Privacy Policy, Terms, and "删除本机数据" (delete local data).

Non-medical: wellness / relaxation only; no diagnosis, treatment or disease management.

Ads: Google AdMob app-open ad, initialized only after the user accepts the privacy policy (UMP + ATT).
AdMob App ID: ca-app-pub-1210970407399902~1873367712
```

---

## 11. 回复审核（2.3 被拒后用）

拒信：Submission ID `f13892cd-9340-41ac-a713-15c80c56a6b7`（2026-11-13，「智能戒指联动」找不到）。改完第 4–7 节和第 10 节后，在 Resolution Center 粘贴：

```
Hello App Review team,

Thank you for your review (Submission ID f13892cd-9340-41ac-a713-15c80c56a6b7).

Regarding Guideline 2.3: the smart ring feature ("智能戒指联动") has been fully removed from the app since version 1.4.0. The build you reviewed, 1.4.0 (11), contains no ring or Bluetooth hardware feature.

We have now updated the metadata to match the app:
- Removed every reference to the smart ring from the description, promotional text and keywords.
- Replaced all iPhone and iPad screenshots; no ring images or ring-related text remain.
- Removed the previous ring demo video link from the App Review Information.

The sleep and heart-rate features now come from Apple Health (read-only, displayed locally):
"休息" tab (4th tab) → "连接 Apple 健康" → allow access. If the device has no Health sleep data, an empty state is shown.

Please continue the review with build 1.4.0 (11).

Best regards,
[Your Name]
```

---

## 12. 送审前自查

- [ ] iPhone 截图逐张确认：没有戒指图片和戒指文字
- [ ] iPad 13" 截图逐张确认：没有戒指图片和戒指文字
- [ ] 每个本地化语言的描述、关键词、截图都已更新
- [ ] App 预览视频（如有）没有戒指画面
- [ ] 审核备注已替换，旧戒指视频链接已删除
- [ ] 描述里的每个功能都能在 App 里找到
- [ ] App 隐私未勾选「健康与健身」
- [ ] 联系电话、邮箱是真实可用的
- [ ] 送审 Build 为 `1.4.0 (11)`
- [ ] 已在 Resolution Center 发送第 11 节回复

---

## 13. 构建（需要传新包时）

```bash
cd App/apps/healing_tabs
# 先把 pubspec 的 Build 号 +1，例如 1.4.0+12
flutter build ipa --release
```

内部已知事项（不写进审核备注）：音频 CDN 仍有 HTTP 例外域名 `139.199.211.157`，计划迁 HTTPS。
