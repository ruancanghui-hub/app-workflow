# Core Tab UI QA

## 结果

- 首页源文件复制校验：PASS（SHA-256 均为 `c11090bce923be939afee74c2603676ee9be6dcae7cea295ac2122c982b8c260`）
- 四张画布：PASS（853 × 1844 px）
- 根 Tab 顺序与文案：PASS（今晚、声音、睡眠、我的）
- P0 信息架构映射：PASS
- 医疗/睡眠分期越界：PASS（未出现）
- 视觉体系一致性：PASS
- 生成图底栏像素一致：LIMITATION（生成图标与局部几何存在轻微漂移）
- 第三阶段共享 Tab 组件约束：REQUIRED

## 判定

`PASS_WITH_RASTER_LIMITATION`。三张扩展图作为骨架视觉参考通过；不可将其底栏宣称为像素相同。可点击原型及后续 Flutter 必须复用单一 Tab 组件，只切换 `activeTab`。

