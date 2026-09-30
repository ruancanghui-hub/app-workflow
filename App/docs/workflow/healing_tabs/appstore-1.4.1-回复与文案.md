# 云遥 · App Review 1.4.1 / 2.1 回复与商店文案（过审软化版）

对应拒信 Submission ID：`94596c81-7da1-4bd5-9050-98899118295e`  
工程软化包建议版本：`1.3.9 (9)`（`pubspec`: `1.3.9+9`）

---

## A. 回复 App Review（英文，直接粘贴）

> 演示视频已填：https://youtube.com/shorts/scWhBgGP8eE  
> 若已上传新 build，把版本号改成实际上传的。

```
Hello App Review team,

Thank you for the feedback on 云遥 (YunYao), Submission ID 94596c81-7da1-4bd5-9050-98899118295e.

## Guideline 1.4.1 — clarification (not a medical device / medical service)

YunYao is a consumer wellness / lifestyle relaxation app. It is NOT a medical device app and does NOT provide medical services.

- The optional “YunYao Ring” is a consumer lifestyle wearable accessory for relaxation context. It is not marketed, cleared, or intended as a medical device.
- The app does not diagnose, treat, cure, or manage any disease or condition.
- Optional sleep duration summaries and heart-rate reference curves are lifestyle metrics stored locally for personal relaxation context only. They are not clinical monitoring and must not be used for medical decision-making.
- Because the product is not a medical device and does not provide medical services, Guideline 1.4.1 (regulatory clearance for medical hardware / medical services) does not apply. We therefore cannot and should not provide medical regulatory clearance documentation.

We have updated App Store metadata and in-app wording to make this positioning clearer (wellness / lifestyle; non-medical; optional accessory). Please review build 1.3.9 (9) (or the latest build attached to this reply).

## Guideline 2.1 — hardware demo video

Demo video (physical iPhone + ring pairing and workflow):
https://youtube.com/shorts/scWhBgGP8eE

The video shows:
1) The current app running on a physical Apple device (not a simulator)
2) Initial Bluetooth pairing between the app and the designated ring hardware
3) The main in-app workflow while the ring is connected (relaxation / local summary / optional heart-rate reference)

## Sign-in

No account is required. After accepting the privacy policy, the reviewer can use all core features. Ring pairing is optional for the audio / breathing features; the video demonstrates the hardware path when the accessory is available.

Privacy Policy:
https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html

Please let us know if you need any additional clarification.

Best regards,
[Your Name]
[Support email / phone]
```

---

## B. 商店描述（ASC 粘贴，替换旧文案）

### 推广文本

```
自然声景、呼吸练习与可选生活方式戒指，陪你放松入睡。本地保存休息摘要；非医疗器械，不提供诊断或治疗。
```

### 描述

```
云遥是一款面向成人的放松与睡眠陪伴 App（Wellness / 生活方式），不是医疗器械，也不提供医疗服务。

核心功能：
• 自然声景播放：包内与服务器音频，支持收藏与专注倒计时
• 呼吸练习：4-7-8 节奏，可配自然之声与时长
• 冥想入口：日间自然声景与专注白噪
• 可选云遥戒指（生活方式配件）：配对后可在本机查看休息时长摘要与心率参考曲线，仅供放松参考
• 开屏广告：Google AdMob（首次需同意隐私政策）

无需强制注册。使用本机云遥身份；可在「我的」中删除本机数据。

重要声明：本 App 与可选戒指均为消费级 wellness 产品，不用于医疗诊断、治疗、临床监护或疾病管理。如有健康问题，请咨询专业医生。

隐私政策：https://ruancanghui-hub.github.io/app-workflow/yunyao/privacy-policy.html
用户协议：https://ruancanghui-hub.github.io/app-workflow/yunyao/terms.html
```

### 关键词（可微调）

```
睡眠,白噪音,冥想,放松,声景,呼吸,助眠,减压,戒指,生活方式
```

（去掉偏「临床心率监测」感的词即可；保留「戒指」无妨。）

---

## C. 审核备注（App Review Information，中英皆可）

```
【非医疗 / Wellness】
YunYao is a consumer wellness app. The optional ring is a lifestyle accessory, NOT a medical device. No diagnosis, treatment, or clinical monitoring. Local rest summaries & heart-rate references are for relaxation only.

【演示视频】
https://youtube.com/shorts/scWhBgGP8eE
Shows physical iPhone + ring pairing + main workflow.

【测试步骤】
1. Cold start → accept Privacy Policy → Home
2. Play nature sounds / Focus / Breath
3. Sleep tab → play a track
4. Device tab → (optional) pair ring → local rest summary / heart-rate reference
5. Me → Privacy Policy / Delete local data

【账号】No login required.

【广告】AdMob app-open after consent. App ID: ca-app-pub-1210970407399902~1873367712
```

---

## D. 演示视频拍摄清单（2.1）

1. 用**真机**（勿模拟器），手机与戒指同框  
2. 打开云遥 → 同意隐私（若需）→ 进首页  
3. 戒指 Tab → 搜索 → 配对成功  
4. 走一遍：伴睡/睡前放松或本地摘要、心率参考页  
5. 上传到可公开访问链接（未登录可播）→ 填入 ASC 备注与回复  

**已提供演示视频**：https://youtube.com/shorts/scWhBgGP8eE  

请确认：YouTube 可见性为「公开」或「不公开列出」且**无需登录即可播放**（审核员常用无 Google 登录的环境）。Shorts 可以，但若审核仍要「完整配对流程」，可再补一条稍长的横屏/竖屏完整录像。 

---

## E. 工程已做的软化（本版）

- 首页「睡眠监测」→「睡前放松」  
- 戒指页：休息摘要 / 心率参考；标明生活方式配件、非医疗  
- 配对引导与会话文案去「采集体征 / 监测」医疗感  
- 版本 bump：`1.3.9+9`  
- 法律文案同步 wellness 表述  

上传新 IPA 后：ASC 更新描述 → 粘贴回复 → 附上视频链接 → Reply。
