# festive_greet — 一键启动备忘

## 一句话（已执行 INTAKE + Phase 1）

```text
/app-workflow 智能模式
我想做：节日祝福贺卡 App，选模板写祝词保存分享
Bundle：com.nightelf.festivegreet
平台：iOS 优先，TestFlight 游客闭环，订阅 defer
```

## 当前状态

| Gate | 状态 |
|------|------|
| PRD | **PASS** |
| IP → App Store | PENDING |

`workflow.phase` = **PHASE_2_IP**

## 下一句话（Phase 2 品牌 IP）

```text
进入 Phase 2，为 festive_greet 生成品牌 IP：
四 Tab（首页/模板/我的/设置），国潮喜庆风，春节+中秋模板视觉
```

## 发布流水线（脚手架后从 healing_tabs 复制）

- `.ruby-version` 3.3.6
- `scripts/upload_app_store.sh` + `SKIP_MATCH=true`
- `.env`：`APP_IDENTIFIER=com.nightelf.festivegreet`
- `APP_STORE_CONNECT_API_KEY_KEY_PATH` 指向现有 `.p8`

## 路径

| 项 | 路径 |
|----|------|
| handoff | `App/docs/workflow/festive_greet/handoff-manifest.json` |
| PRD | `App/docs/product/2026-08-30-节庆祝福/` |
| 词汇 | `App/docs/workflow/festive_greet/glossary.md` |
| Flutter（待建） | `App/apps/festive_greet` |
