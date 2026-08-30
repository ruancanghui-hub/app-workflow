# festive_greet 立项 — 工作流演化第二实例

> **目的**：用第二个独立 App 验证 `app-workflow` 可复制，并把与 `healing_tabs` 不同的决策沉淀回 `08_Learn`。

## 与 healing_tabs 的差异

| 维度 | healing_tabs | festive_greet |
|------|--------------|---------------|
| 领域 | 伴睡声景 | 节日贺卡 |
| Bundle | `com.nightelf.yunyao` | `com.nightelf.festivegreet` |
| MVP loop | 声景→睡眠→报告 | 模板→编辑→预览→分享 |
| 订阅 | defer | defer（同样策略） |
| 音频/麦克风 | 需要 NSMicrophoneUsageDescription | 预计不需要（待 Phase 5 确认） |
| 权限重点 | 后台 audio + 麦克风说明 | 相册写入 NSPhotoLibraryAddUsageDescription |

## 可复用（不必重做）

- `08_Learn/app-workflow-全流程指南.md`
- `healing_tabs` 的 `upload_app_store.sh` / Fastfile KEY_PATH 模式
- `.ruby-version` 3.3.6 + mise
- `SKIP_MATCH=true` 本机签名
- handoff-manifest.json 契约结构

## 本 App 应新沉淀的 Playbook（预期）

1. **贺卡类 App Phase 2**：模板视觉 + 四 Tab IA（非疗愈 Tab）
2. **相册导出权限**：Info.plist + 拒权降级
3. **静态模板 bundled 内容规模**：≥6 套验收清单

## 演化登记

第二个 App 立项时执行：

```bash
python3 08_Learn/evolve-workflow/scripts/log_repetition.py \
  --phase prd \
  --pattern "第二个产品从 handoff 模板复制 PRD 五件套" \
  --context "festive_greet 立项验证流程可复制" \
  --product-slug festive_greet
```

## 当前 Gate

见 `App/docs/workflow/festive_greet/handoff-manifest.json` — PRD PASS，Phase 2 IP 待启动。
