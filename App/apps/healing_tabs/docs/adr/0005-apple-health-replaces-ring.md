# Apple 健康取代自研戒指

Status: accepted  
Supersedes: ADR-0003「强依赖戒指」  
Revises（局部）: ADR-0001 Tab 定位；ADR-0004 冥想心率采样方式

自研戒指因 App Store 1.4.1（医疗硬件资质）与 2.1（硬件演示视频）无法过审。改为 **iOS 只读 Apple 健康（HealthKit）** 的睡眠阶段与心率；底栏「戒指」更名为「休息」；Android 隐藏体征入口。不做 watchOS 配套 App，不做 Android Health Connect，不保留戒指开关。

**授权与诚实度**：用户点「连接 Apple 健康」才请求读权限；界面统一写「来自 Apple 健康」。心率不落本地——本地只存冥想 **播放记录** 时间窗，查看时再查 HealthKit。去掉 App 自算分数与质量标签。睡前放松会话与睡眠报告解耦：报告按 **睡眠日** 读健康数据，未开会话也有报告。

**未选方案**：watchOS App（秒级心率，审核面与工作量更大）；双平台 Health Connect；保留戒指代码用开关关闭（审核仍可能追问硬件）。
