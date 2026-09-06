# 云遥 · App Store Connect 提审填写手册

> 用途：打开 ASC 时对照本页逐项粘贴/勾选。  
> 工程：`App/apps/healing_tabs` · Bundle `com.nightelf.yunyao` · Tag `v0.19.0` · 版本 `0.1.0 (2)`  
> 详细展开见同目录 [`app-store-submission.md`](./app-store-submission.md)、[`privacy-questionnaire.md`](./privacy-questionnaire.md)。

---

## 0. 提审前你还要补的三项（文档里是占位）

| 项 | 状态 | 说明 |
|----|------|------|
| 联系邮箱 | ⚠️ 待填 | ASC「App 审核信息」联系邮箱 |
| 联系电话 | ⚠️ 待填 | 含国家码，审核员可打通 |
| 截图 | ⚠️ 待传 | 至少 6.7"、6.5" 各 3 张（见 §8） |

其余元数据、隐私 URL、审核备注、隐私标签建议已齐，可直接用。

---

## 1. App 信息（App Information）

| ASC 字段 | 填写值 |
|----------|--------|
| 名称 | 云遥 |
| 副标题 | 更好的睡眠，更轻的自己 |
| 隐私政策 URL | https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html |
| 类别（主要） | 健康健美 |
| 类别（次要） | 生活方式 |
| 内容版权 | © 2026 Night Elf / 云遥 |

**用户协议（可选补充到描述或支持页）**：  
https://ruancanghui-hub.github.io/app-workflow/yunyao/terms.html

**法律文档目录**：  
https://ruancanghui-hub.github.io/app-workflow/yunyao/

---

## 2. 定价与销售范围

| 项 | 建议 |
|----|------|
| 价格 | 免费 |
| 销售国家/地区 | 按计划选择（含广告：注意欧盟 UMP） |
| App 内购买 | **无**（当前无 IAP / 订阅） |

---

## 3. App 隐私（Privacy）— 按此勾选

隐私政策须与下方一致。公网政策已托管。

### 3.1 是否收集数据？

**是**（同意后含分析/诊断/广告；本机含健康相关数据）。

### 3.2 建议勾选的数据类型

| 数据类型 | 收集 | 用途勾选 | 关联用户身份 | 用于追踪 |
|----------|------|----------|--------------|----------|
| 健康与健身 | 是 | App 功能 | **否**（默认仅本机） | 否 |
| 产品交互 / 使用数据 | 是（同意后） | 分析 | 可能（Firebase 安装级） | 否* |
| 诊断 | 是（同意后） | App 功能 / 分析 | 可能 | 否 |
| 设备 ID | 是（同意后，广告） | 第三方广告 | 由 SDK 管理 | **视 ATT**：个性化广告则勾追踪 |

\* 非「跨 App 追踪」用途时，使用数据不必勾追踪；**若 AdMob 使用 IDFA 做个性化**，在「用于追踪的数据」中披露设备 ID（及 ASC 要求的相关项）。

### 3.3 第三方

- Google Firebase（Analytics / Crashlytics / Remote Config）
- Google AdMob（开屏广告）

不出售用户数据。

### 3.4 用户可删除的数据

「我的 → 删除本机数据」可清除本机账号、睡眠、收藏、配对缓存、同意状态并回到首次同意门。

---

## 4. 年龄分级（Age Rating）

| 项 | 建议 |
|----|------|
| 目标 | **17+** |
| 原因 | 含广告；面向成人；非儿童 App |
| 医疗/治疗声明 | 无（Wellness，非诊断） |
| 不受限网页 | 无 |
| 赌博/暴力等 | 无 |

按问卷如实答「含广告」相关项。

---

## 5. App 加密与出口合规

| 问题 | 答案 |
|------|------|
| 是否使用加密？ | 是（仅标准 HTTPS/TLS） |
| 是否豁免？ | **是** — `ITSAppUsesNonExemptEncryption = false` |
| ASC「出口合规」 | 选择仅使用豁免加密 / 不需出口合规文件 |

---

## 6. 版本信息（Version）

| ASC / 工程字段 | 值 |
|----------------|-----|
| Bundle ID | `com.nightelf.yunyao` |
| SKU | `yunyao_v1` |
| 版本号（Marketing） | `0.1.0` |
| Build | `2`（`pubspec`：`0.1.0+2`） |
| 最低系统 | iOS 15.0 |
| Git Tag | `v0.19.0`（`feature_app`） |

**递增**：每次上传新包 Build +1；对外大改再 bump `0.1.x`。

### 6.1 推广文本（Promotional Text，可随时改）

```
用自然声景、呼吸练习与可选智能戒指监测，帮助你放松入睡、关注基础睡眠与心率变化。数据默认保存在本机；非医疗诊断。
```

### 6.2 描述（Description）

```
云遥是一款面向成人的身心放松与睡眠陪伴 App。

核心功能：
• 自然声景播放：包内与服务器音频，支持收藏与专注倒计时
• 睡眠监测与报告：配对云遥戒指后记录监测会话，查看本地报告（有真数据才展示阶段/曲线）
• 呼吸练习：4-7-8 节奏，可配自然之声与时长
• 冥想入口：日间自然声景与专注白噪
• 开屏广告：Google AdMob（首次需同意隐私政策）

无需强制注册。使用本机云遥身份；可在「我的」中删除本机数据。

本产品不提供医疗诊断、失眠治疗或临床睡眠分期结论。如有持续睡眠问题，请咨询专业医生。

隐私政策：https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html
用户协议：https://ruancanghui-hub.github.io/app-workflow/yunyao/terms.html
```

### 6.3 关键词（Keywords，逗号分隔，无空格亦可）

```
睡眠,白噪音,冥想,放松,声景,呼吸,助眠,减压,戒指,心率
```

### 6.4 技术支持 URL / 营销 URL（可选）

| 字段 | 建议 |
|------|------|
| 技术支持 URL | 可用隐私政策页或自建支持页；暂无则可先用隐私政策 URL |
| 营销 URL | 可选；暂无可留空 |

---

## 7. App 审核信息（App Review Information）

| 字段 | 填写 |
|------|------|
| 名字 / 姓氏 | 开发者真实姓名 |
| 电话 | ⚠️ **待填**（可打通） |
| 邮箱 | ⚠️ **待填** |
| 登录所需？ | **否** |
| 演示账号 | 无需 — 同意政策后即可使用 |
| 备注 | 粘贴下方整段 |

### 审核备注（全文粘贴）

```
【测试步骤】
1. 冷启动 → 首次同意隐私政策与用户协议 → 进入首页
2. 首页播放场景声 / 心流专注 / 呼吸练习
3. 睡眠 Tab → 打开自然白噪音条目 → 播放器播控
4. 戒指 Tab →（可选）扫描配对戒指 → 睡眠监测 / 睡眠报告 / 心率趋势
5. 我的 → 隐私政策 / 用户协议 / 删除本机数据（请勿在审核流程中误删后中断体验）

【账号】
无强制登录。本机云遥身份；支持「删除本机数据」。

【非医疗声明】
Wellness / 放松辅助工具，不诊断、不治疗疾病。
睡眠阶段图与心率曲线仅在有真实监测/采样数据时展示，不合成演示分期冒充真监测。

【广告】
含 AdMob 开屏广告。首次同意后初始化 Mobile Ads；含 UMP 同意与 ATT（如系统需要）。
AdMob App ID: ca-app-pub-1210970407399902~1873367712

【后台音频】
UIBackgroundModes: audio；伴睡/播放可后台续播，支持锁屏播控。

【加密】
ITSAppUsesNonExemptEncryption = false（仅标准 HTTPS/TLS）。

【已知限制】
- 音频 CDN 仍可能使用 HTTP（ATS 例外域名 139.199.211.157），计划迁 HTTPS
- 订阅付费墙未接入；当前核心功能免费
- 人声故事等节目待有真素材后再上架；当前为可诚实播放的自然声景

【隐私政策】
https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html
```

---

## 8. 截图与预览

| 设备 | 尺寸 | 最少 | 建议画面（勿展示未上线付费墙/假医疗结论） |
|------|------|------|------------------------------------------|
| 6.7" | 1290×2796 | 3 | ① 首页场景 ② 睡眠声景列表/播放 ③ 戒指页或报告空态/真数据 |
| 6.5" | 1284×2778 | 3 | 同上 |
| 其他尺寸 | 按 ASC 要求 | 按需 | 可复用同构图 |

本地归档目录（勿含真实用户隐私）：`App/docs/workflow/healing_tabs/screenshots/`

---

## 9. 构建与上传清单

```bash
cd App/apps/healing_tabs
# 确认 pubspec version，例如 0.1.0+2；再提审请 Build +1
flutter build ipa --release
# 或团队既有 scripts/upload_app_store.sh
```

上传后：

1. TestFlight 内部测试：冷启动同意门 → 首页播放 → 我的政策外链 →（可选）删数据重置  
2. 确认同意前**无**开屏广告  
3. 选中该 Build → 提交审核  

### 权限文案（审核员系统弹窗会看到）

| 权限 | 用途 |
|------|------|
| 蓝牙 | 搜索并连接云遥智能戒指 |
| 定位（使用期间） | 附近扫描戒指；不追踪行踪 |
| 跟踪（ATT） | 相关广告 |
| 后台音频 | 伴睡/播放续播 |

无麦克风用途声明（当前不录音）。

---

## 10. 一页验收（送审前打勾）

- [ ] ASC 隐私政策 URL 可浏览器打开  
- [ ] App 隐私标签已按 §3 保存  
- [ ] 年龄分级 17+、含广告如实  
- [ ] 出口合规：仅豁免加密  
- [ ] 审核联系电话/邮箱已换成真实可用  
- [ ] 审核备注已粘贴 §7  
- [ ] 无「需登录」；无演示账号也可玩通主路径  
- [ ] 截图已上传且与真实功能一致（无假分期/无虚假会员购买）  
- [ ] TestFlight 主路径通过；同意前无广告  
- [ ] 构建 Bundle = `com.nightelf.yunyao`，版本与 ASC 一致  

---

## 11. 相关链接速查

| 用途 | URL / 路径 |
|------|------------|
| 隐私政策 | https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html |
| 用户协议 | https://ruancanghui-hub.github.io/app-workflow/yunyao/terms.html |
| AdMob App ID | `ca-app-pub-1210970407399902~1873367712` |
| 开屏广告单元 | `ca-app-pub-1210970407399902/8968530151` |
| 本手册 | `App/docs/workflow/healing_tabs/appstore-提审填写手册.md` |
| 提交元数据原文 | `app-store-submission.md` |
| 隐私问卷原文 | `privacy-questionnaire.md` |

---

**说明**：本手册表示「材料可填、可送审」；审核结果由 Apple 决定。若被拒，根据 Rejection 更新本文件与工程后再传新 Build。
