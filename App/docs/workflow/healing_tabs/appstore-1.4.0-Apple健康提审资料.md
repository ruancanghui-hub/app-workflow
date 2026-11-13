# 云遥 · 1.4.0 Apple 健康版 · App Store Connect 填写资料

> 对应拒信：Submission ID `f13892cd-9340-41ac-a713-15c80c56a6b7`（2026-11-13，Guideline 2.3 Accurate Metadata）  
> 审核设备：iPad Air 11-inch (M3) · 审核版本：`1.4.0 (11)`  
> 工程：`App/apps/healing_tabs` · 分支 `feature_apple_watch` · Bundle `com.nightelf.yunyao` · `pubspec` `1.4.0+11`  
> 本文件取代 [`appstore-1.4.1-回复与文案.md`](./appstore-1.4.1-回复与文案.md) 中所有戒指相关内容。

---

## 0. 这次为什么被拒、要改什么

审核员在元数据里看到 **「智能戒指联动」**，但 App 里找不到这个功能（1.4.0 已移除戒指、改用 Apple 健康）。

**App 二进制本身不用改。** `1.4.0 (11)` 里已经没有任何戒指 / 蓝牙配对的界面文字。要改的是 App Store Connect 里的元数据：

| 位置 | 要做的事 |
|------|----------|
| iPhone 截图（6.9" / 6.5"） | 删除所有带「戒指 / 智能戒指联动 / 配对戒指 / 戒指图片」的图，换成 §4 的新截图 |
| **iPad 截图（13"）** | **同上，这次审核员用的是 iPad，重点检查这一组** |
| App 预览视频（如有上传） | 有戒指画面就删掉 |
| 推广文本 / 描述 / 关键词 / 副标题 | 用 §2 的新文案整段替换 |
| 审核备注 | 用 §5 替换；删除旧的 YouTube 戒指演示视频链接 |
| 每个已添加的本地化语言 | **每个语言都要单独检查一遍**，英文/繁中等页面最容易漏改 |

> 首次上架的 App 没有「此版本新增内容（What's New）」，不用填。

**是否需要上传新 Build：不需要。** 元数据和截图在被拒状态下可以直接编辑，改完后在 ASC 回复审核即可，继续用 `1.4.0 (11)` 送审。

---

## 1. App 信息（App Information）— 不变

| ASC 字段 | 填写值 |
|----------|--------|
| 名称 | 云遥 |
| 副标题 | 更好的睡眠，更轻的自己 |
| 隐私政策 URL | https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html |
| 类别（主要） | 健康健美 |
| 类别（次要） | 生活方式 |
| 内容版权 | © 2026 Night Elf / 云遥 |
| 价格 | 免费 · 无 App 内购买 |

---

## 2. 版本文案（整段替换）

### 2.1 推广文本（Promotional Text）

```
自然声景、呼吸练习与冥想，陪你放松入睡。可选连接 Apple 健康，在本机查看休息摘要与心率参考；非医疗用途。
```

### 2.2 描述（Description）

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

### 2.3 关键词（Keywords）

```
睡眠,白噪音,冥想,放松,声景,呼吸,助眠,减压,专注,Apple健康
```

> 不要出现：戒指、智能戒指、穿戴设备、配对、蓝牙、监测、诊断。

### 2.4 技术支持 URL / 营销 URL

| 字段 | 填写 |
|------|------|
| 技术支持 URL | https://ruancanghui-hub.github.io/app-workflow/yunyao/ |
| 营销 URL | 留空 |

---

## 3. App 隐私（Privacy）— 勾选

| 数据类型 | 收集 | 用途 | 关联身份 | 用于追踪 |
|----------|------|------|----------|----------|
| 健康与健身 | **不勾选**（HealthKit 只在本机展示、不传出设备，按 Apple 定义不算「收集」） | — | — | — |
| 产品交互 | 是（同意后，Firebase Analytics） | 分析 | 否 | 否 |
| 崩溃数据 / 性能数据 | 是（同意后，Crashlytics） | App 功能 | 否 | 否 |
| 设备 ID | 是（同意后，AdMob） | 第三方广告 | 否 | **用户允许 ATT 时为「是」** |

第三方 SDK：Google Firebase、Google AdMob。不出售用户数据。  
详细依据见 [`privacy-questionnaire.md`](./privacy-questionnaire.md)。

### 其他固定项

| 项 | 填写 |
|----|------|
| 年龄分级 | 17+（含广告，面向成人；无医疗/治疗信息） |
| 出口合规 | 仅使用豁免加密（`ITSAppUsesNonExemptEncryption = false`） |
| HealthKit 能力 | Xcode / 开发者后台已开启 HealthKit；审核备注里说明用途（见 §5） |

---

## 4. 截图（必须重做的部分）

### 4.1 必传尺寸

| 设备组 | 尺寸（竖屏） | 张数 |
|--------|--------------|------|
| iPhone 6.9" | 1320×2868 或 1290×2796 | 3–10 |
| iPhone 6.5"（如 ASC 要求） | 1284×2778 或 1242×2688 | 3–10 |
| **iPad 13"** | **2064×2752 或 2048×2732** | **3–10（本 App 支持 iPad，必传）** |

### 4.2 建议截图顺序（iPhone 与 iPad 各一套）

| # | 画面 | 宣传标题（可叠在截图上） |
|---|------|--------------------------|
| 1 | 首页场景 + 三个入口（睡前放松 / 心流专注 / 呼吸练习） | 在自然中，找回内心的平静 |
| 2 | 睡眠 Tab 声景列表或播放器 | 自然声景 · 沉浸助眠 |
| 3 | 呼吸练习页 | 4-7-8 呼吸 · 慢下来 |
| 4 | 冥想 Tab | 冥想减压 · 找回平静 |
| 5 | 休息 Tab：「连接 Apple 健康」卡片，或已授权后的休息摘要 | **连接 Apple 健康 · 本地休息摘要** |
| 6 | 睡眠报告 / 心率参考页（有真实数据时再用） | 休息与心率参考 · 非医疗用途 |

### 4.3 截图红线

- 画面和文字里**不能出现**：戒指实物图、「智能戒指联动」「配对戒指」「同步戒指」「戒指 Tab」
- 截图必须是当前 `1.4.0 (11)` 真实界面；底栏第 4 个 Tab 显示为「休息」
- 宣传海报底部的四个图标里，旧版「智能联动 · 记录身心」改成「Apple 健康 · 休息摘要」，图标换成心形或健康图标
- 不展示假的睡眠阶段 / 假评分；没数据就用「连接 Apple 健康」卡片那张
- 宣传语避免「监测、诊断、治疗、更健康」这类医疗暗示词；「更平静、更好的睡眠、放松」可以

---

## 5. App 审核信息（App Review Information）

| 字段 | 填写 |
|------|------|
| 需要登录 | 否 |
| 演示账号 | 留空（无需登录） |
| 联系人 / 电话 / 邮箱 | 填真实可联系的信息 |
| 附件 / 演示视频 | **删除旧的戒指演示视频链接** |

### 审核备注（整段粘贴）

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
```

---

## 6. 回复审核（Resolution Center，粘贴后点「发送」）

### 英文（推荐）

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

### 中文（如更习惯中文可用这份）

```
您好，

感谢审核（Submission ID：f13892cd-9340-41ac-a713-15c80c56a6b7）。

关于 2.3：「智能戒指联动」功能自 1.4.0 起已从 App 中完全移除，本次审核的 1.4.0 (11) 不包含任何戒指或蓝牙硬件功能。

我们已更新元数据与 App 保持一致：
- 描述、推广文本、关键词中删除了所有戒指相关表述；
- 重新上传了全部 iPhone 与 iPad 截图，不再包含戒指图片或文字；
- 删除了 App 审核信息中旧的戒指演示视频链接。

睡眠与心率参考现改为读取 Apple 健康（只读、仅本机展示）：
第 4 个「休息」Tab → 点击「连接 Apple 健康」→ 允许读取。若设备没有健康睡眠数据，会显示空状态。

请继续审核 1.4.0 (11)。谢谢！
```

---

## 7. 送审前自查清单

- [ ] iPhone 截图组：逐张确认无戒指图片、无「戒指」字样
- [ ] **iPad 13" 截图组：逐张确认无戒指图片、无「戒指」字样**
- [ ] 所有本地化语言（简中 / 英文 / 其他）的描述、关键词、截图都已改
- [ ] App 预览视频（如有）已删除戒指画面
- [ ] 审核备注已替换为 §5，旧 YouTube 戒指视频链接已删
- [ ] 描述中写的每个功能都能在 App 里找到：声景、专注、呼吸、冥想、休息（Apple 健康）、广告、删除本机数据
- [ ] App 隐私：未勾选「健康与健身」
- [ ] 送审 Build 仍为 `1.4.0 (11)`
- [ ] 在 Resolution Center 发送 §6 回复

---

## 8. 相关文件

| 用途 | 路径 |
|------|------|
| 本文件 | `App/docs/workflow/healing_tabs/appstore-1.4.0-Apple健康提审资料.md` |
| 通用提审手册 | [`appstore-提审填写手册.md`](./appstore-提审填写手册.md) |
| 隐私问卷 | [`privacy-questionnaire.md`](./privacy-questionnaire.md) |
| 旧版戒指回复（已作废） | [`appstore-1.4.1-回复与文案.md`](./appstore-1.4.1-回复与文案.md) |
