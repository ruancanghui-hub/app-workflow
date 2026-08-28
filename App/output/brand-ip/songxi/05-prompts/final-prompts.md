# 松息 / 松芽 Songya — Final Prompt Set

## 生成路线

- 路线：Codex 内置 `imagegen`
- 角色锚点：`../01-character-concepts/character-anchor.png`
- use-case 分类：`stylized-concept`、`logo-brand`、`illustration-story`、`ui-mockup`
- 下游资产均将角色锚点作为唯一身份参考。
- `12ui` CLI 已安装，但未连接账户，因此本轮没有使用其托管生成；UI 方向由 `imagegen` 完成。

## 角色概念公共提示词

```text
Use case: stylized-concept
Asset type: canonical mascot concept sheet, 16:9 landscape
Create one clean two-view concept sheet for Songya, an original pine-seed spirit mascot for the adult sleep app 松息. Warm off-white seamless studio background. Show exactly two depictions of the exact same character: left full-body front-standing premium 3D render and right matching full-body flat 2D vector-style depiction. Integrated soft teardrop body, upper head about 55%, exactly two short simple smooth solid tapered leaf ears total, exactly three large rounded forehead scales arranged one above two, dark night-blue half-closed oval eyes without whites, no snout, tiny low-contrast curved mouth, two short round arms and two short round feet fully visible, one warm amber hollow circular breathing ring centered on chest. Palette #183D35 body, #101A2A eyes/shadow, #DDE8DE face, #F2C879 ring, optional tiny #C98263. Quiet, safe, restorative, adult, original, buildable. No text, captions, logo, watermark, extra views, clothes, props, tail, wings, stars, moons, medical symbols, neon, shiny plastic, busy texture, animal anatomy, or resemblance to an existing character.
```

### 受控变量

1. Concept 01：短密植绒主体、哑光陶瓷脸部、平衡比例。
2. Concept 02：略宽下身、小脚、层叠羊毛毡与纸纤维质感。
3. Concept 03：约 10% 更高更窄、微植绒主体、无缝陶瓷脸部。
4. Concept 04：平稳底部、细密 boucle 织物、哑光陶土脸部嵌片。
5. Concept 05：柔和几何切面、压缩纸浆外壳、细毡脸部、大色块；最终锚点。
6. Concept 06：低重心抱枕比例、绗缝微麂皮与哑光陶瓷脸部。

### 定向修正

- Concept 01：将多分枝松针扇替换为每侧一片、共两片的光滑单叶耳。
- Concept 02：额部改为严格三瓣，一上两下。
- Concept 03：额部改为严格三瓣；叶耳去除羽状纹和分枝。
- Concept 04：主体与叶耳改为深松绿 `#183D35`，保留雾白脸部。

## App Icon

```text
Use case: logo-brand
Asset type: square App Icon master artwork for iOS
Input images: Image 1 is the only canonical identity reference for Songya.
Create a polished square app icon master for the adult sleep app 松息 using the exact Songya identity from Image 1. Show a close centered head-and-upper-body silhouette with two single leaf ears, exactly three forehead scales, half-closed night-blue eyes, mist-white face inset, and a small visible warm amber hollow chest breathing ring. Preserve the geometric pine-seed silhouette and matte compressed-pulp/felt tactility. Use a simple deep night-blue to deep-pine full-bleed field, quiet lighting and a bold silhouette readable at 32 px. No text, wordmark, external rounded-square mask, border, device mockup, watermark, extra objects, stars or moons. Do not redesign the character.
```

## Launch Screen

```text
Use case: stylized-concept
Asset type: 9:16 portrait launch artwork for iOS
Input images: Image 1 is the only canonical identity reference for Songya.
Create a refined launch illustration with the exact Songya character standing calmly in the lower-middle of an abstract night soundscape. Preserve the geometric pine-seed silhouette, two leaf ears, exactly three forehead scales, half-closed eyes, short limbs and hollow amber chest ring. Use abstract deep-pine and night-blue acoustic waves, not a literal forest, and leave large calm negative space in the upper half for native app text. No generated text, letters, logo, watermark, stars, moons, medical symbols, device frame, extra characters or props.
```

## 15 动作表

```text
Use case: illustration-story
Asset type: 3:4 expression and action system sheet
Input images: Image 1 is the only canonical identity reference for Songya.
Create exactly one 3-column by 5-row grid with exactly 15 equal cells, one full-body Songya action per cell. Preserve the exact anchor identity in every cell. Actions in reading order: loading, refresh, sort, scroll, tap, delete, paste, like, favorite using a bookmark-shaped leaf, share, follow, upload, download, submit, cancel. Clean warm off-white sheet, thin low-contrast gutters, consistent camera and scale. Exactly 15 cells, no captions, words, numbers, watermark, stars, moons or identity drift.
```

## Core Tab UI 公共约束

```text
Use case: ui-mockup
Asset type: 16:9 landscape brand UI direction board for a real iOS mobile app
Input images: Image 1 is the canonical Songya identity reference; use only a restrained small depiction.
Product: 松息. Core tab: 今晚. Bottom navigation items are exactly 今晚、声音、睡眠、我的; 今晚 is selected. Allowed MVP functions: recommended natural soundscape, start sleep session, quick 4-7-8 breathing, alarm, offline download state and basic non-medical sleep report. Required copy: 今晚、声音、睡眠、我的、开始今晚、快捷呼吸、昨夜 7小时24分. Show one coherent borderless mobile UI screen, no phone hardware or decorative device frame. Use real touch targets and practical hierarchy. No watermark, medical charts, sleep-stage claims, AI features, social feed, stories, meditation courses or focus timer.
```

### Direction 01 — Light Brand-led

暖雾白背景、深松绿主色、琥珀只用于状态和主行动；大圆角松籽卡片、松芽陪伴、大片留白、哑光纸毡触感。

### Direction 02 — Dark Immersive

夜蓝与深松绿沉浸背景、低对比声波、琥珀息环作为会话控制；高可读性、无霓虹、角色低占比。

### Direction 03 — Modular Implementation-oriented（推荐）

8pt 栅格、可复用中圆角卡片、双列昨夜/呼吸模块、全宽声景与主按钮；直接映射 SwiftUI 组件，优先可访问性和工程可实现性。
