# 假设与推定

## 用户明确提供

- 产品类型：节日祝福应用  
- Bundle ID：`com.nightelf.festivegreet`  
- 发布策略：TestFlight + 游客闭环  
- 订阅：defer MVP+1  
- 要求：完整 app-workflow + 一键上传（同 healing_tabs）

## 来源确认

- iOS 相册写入需 `NSPhotoLibraryAddUsageDescription`（Apple 审核指南）  
- Canva 等工具验证「模板→编辑→导出」范式可行

## 技能推定

| 推定 | 影响 | 可逆 | 验证 |
|---|---|---|---|
| 产品名「节庆祝福」 | 文档与商店文案 | 易 | 用户确认展示名 |
| slug `festive_greet` | 目录与工程名 | 中 | handoff 已写 |
| 四 Tab：首页/模板/我的/设置 | IA 与原型工作量 | 中 | Phase 3 评审 |
| bundled ≥6 模板可过 MVP | 内容与工期 | 易 | Phase 2 品牌交付 |
| 同 Team JH8478GAY6 签名 | 发布配置 | 易 | .env 复用 |
| 不采集麦克风 | 隐私标签简单 | 易 | 无音频播放则无需 mic plist |

## 待验证事项

- App Store Connect 是否已创建 `com.nightelf.festivegreet` 记录  
- 商店展示名是否与「节庆祝福」一致  
- 模板视觉风格偏好（国潮 / 简约 / 插画风）— Phase 2 前确认
