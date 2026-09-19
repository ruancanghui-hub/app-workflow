# 运维底座默认 Firebase，且经薄接口接入

App 模板的**运维底座**包含**行为埋点**、**远程配置**（含**功能开关**）与**缺陷定位**。远程配置与缺陷定位默认仍为 Firebase（Remote Config + Crashlytics）；行为埋点在配置友盟 key 时优先友盟，否则再 Firebase Analytics / Fake（见 ADR 0006）。模板暴露薄接口并由适配器实现，以便模板实例在不改业务调用点的前提下替换供应商；不把运营内容位/CMS 放进模板。构建变体仅 `dev` / `prod`。
