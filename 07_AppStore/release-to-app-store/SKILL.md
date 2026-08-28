---
name: release-to-app-store
description: >-
  准备并提交 iOS App Store 上架：证书、截图、隐私问卷、TestFlight、审核备注与提审。
  Use when QA passed and user wants App Store release, TestFlight, 上架, 提审, or store submission.
---

# Release to App Store

将 QA 通过的 prod 构建，以可审计的提交包送达 App Store Connect，并完成 TestFlight → 提审。

## Prerequisites

- `gates.qa == "PASS"`
- Apple Developer 账号可用（团队 ID、Bundle ID、证书）
- `flutter-app-template` iOS flavor `prod` 已配置（见 `ios/FLAVORS.md`）
- 隐私政策 URL 可访问（若收集用户数据）

## Inputs

| 来源 | 用途 |
|------|------|
| `02-PRD.md` | 描述、关键词、类别 |
| `qa-report.md` | 已知限制写入审核备注 |
| `03-MVP范围.md` | 功能范围与排除项 |
| `phases.flutter.*` | Bundle ID、展示名 |
| `phases.brand.icon_path` | 商店图标源 |

## Workflow

1. 用 `assets/app-store-submission-template.md` 创建 `docs/workflow/<product_slug>/app-store-submission.md`。
2. 用 `assets/privacy-questionnaire-template.md` 填写隐私标签与数据收集声明；与 PRD 数据章节一致。
3. **Prod 构建预检**（见 `references/ios-release-checklist.md`）:
   - Xcode `prod` scheme
   - `flutter build ipa --flavor prod --dart-define=APP_VARIANT=prod --dart-define-from-file=dart_defines.prod.json`
   - 版本号 / build 号递增规则记录于 submission 文档
4. **商店素材**：6.7" 与 6.5" 截图（至少各 3 张主路径）；预览文案来自 PRD 一句话价值。
5. **TestFlight**：上传 IPA → 内部测试 → 主路径 smoke → 记录 build 号。
6. **提审**：审核备注说明测试账号、非医疗/金融声明（如适用）、已知限制引用 qa-report defer 项。
7. 重复性上架步骤第三次 → `08_Learn/evolve-workflow` 沉淀 playbook。
8. Gate:

```bash
python3 07_AppStore/release-to-app-store/scripts/validate_app_store_package.py \
  docs/workflow/<product_slug>/app-store-submission.md
```

9. 提审提交后设 `gates.app_store = "PASS"`（表示提交包完整且已送审，非 garantee 审核通过）。

## Scope rules

- Default iOS App Store; Android Play 需用户明确要求另开 track。
- Never commit certificates, provisioning profiles, or API keys.
- Store listing must match actual MVP behavior; no placeholder features.
- Health apps: no diagnosis claims; link privacy policy for health data.

## Required outputs

```
docs/workflow/<product_slug>/
├── app-store-submission.md
├── privacy-questionnaire.md
└── screenshots/          # 本地归档，勿含真实用户数据
```

## Final response

TestFlight build 号、submission 文档链接、隐私摘要、审核备注要点、gate PASS。明确：审核结果未知；拒绝时需更新 submission 并可能回到 QA/Feature 阶段。

## Common mistakes

- Submitting dev bundle ID or debug build.
- Privacy labels contradict in-app behavior.
- Screenshots showing features not in MVP.
- Skipping review notes for login-required apps.
