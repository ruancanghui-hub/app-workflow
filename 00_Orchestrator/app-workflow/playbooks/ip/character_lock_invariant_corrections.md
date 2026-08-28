---
phase: ip
pattern_id: ip:character_lock_invariant_drift
title: 角色锁不可变特征的生成与定向修正
count_at_promotion: 4
promoted_at: 2026-08-28
promoted_to:
  - path: 02_IP/APP品牌IP生成/references/character-lock-invariant-corrections.md
    section: "Invariant matrix and targeted retry"
---

# Playbook: 角色锁不可变特征的生成与定向修正

## 触发条件

品牌 IP 已有 character lock，准备批量生成角色概念、图标、启动页、动作表或 UI 衍生图时套用。只要图片中存在可计数或不可漂移的身份特征（耳朵数量、额纹数量、标记位置、主色、肢体、道具），必须在首次生成前使用。

## 前置

- 工具：内置 `imagegen`、本地图片查看工具、`sips`
- 输入：已批准的 character lock
- 路径：项目交付目录与 `character-anchor.png`

## 步骤

1. 把 character lock 转为可逐项检查的 invariant matrix：特征、精确要求、允许变量、禁止漂移、检查结果。
2. 每张图片只开放一个受控变量，例如材质或 10% 内的比例；所有不可变特征在每个 prompt 中重复。
3. 每张图片生成后立即检查数量、位置、轮廓、主色、完整肢体和水印。未通过的图片不能进入 anchor 候选。
4. 保留失败首稿，只做一次定向编辑：`Change only <failed invariant>; keep <passed invariants> unchanged.` 不要重写整个 prompt。
5. 即使批量生成多个概念，每张候选概念图也按一个独立资产计算，分别最多两次总尝试。第二次仍失败则标记该候选缺失并停止依赖它的下游生成，禁止静默替换。
6. 只有通过 invariant matrix 的概念才可选为唯一 `character-anchor.png`；图标、启动页、动作表与 UI 必须引用该锚点。

```bash
test -s output/brand-ip/<slug>/01-character-concepts/character-anchor.png
sips -g pixelWidth -g pixelHeight \
  output/brand-ip/<slug>/01-character-concepts/character-anchor.png
```

## 验收

- [ ] 每个不可变特征都有明确的 PASS / FAIL 记录
- [ ] 概念板的视图数、耳朵数、额纹数、肢体数和身份标记与 lock 一致
- [ ] 重试只修改失败项，成功构图和特征保持不变
- [ ] 单资产没有超过两次总尝试
- [ ] 下游资产全部引用唯一 anchor，而不是漂移变体或纯文字

## 反哺记录

| 目标 Skill | 文件 | 章节 | 状态 |
|------------|------|------|------|
| generate-app-brand-ip | `02_IP/APP品牌IP生成/references/character-lock-invariant-corrections.md` | Invariant matrix and targeted retry | merged |

## 来源

- repetition-log id: ip:character_lock_invariant_drift
- 典型 context: Concept 04 将深松绿主体生成成雾白
