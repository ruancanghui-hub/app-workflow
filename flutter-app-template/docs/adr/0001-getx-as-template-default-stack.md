# 选用 GetX 作为 App 模板默认栈

通用 App 模板需要一套开箱即用的路由、依赖注入与状态约定。候选包括 Riverpod、bloc 与「不锁状态库」。为降低模板实例的学习分叉、并与既有团队偏好对齐，决定模板内 **路由 + Bindings/DI + Controller 状态** 统一使用 GetX，并约定 `feature → binding → controller → pages` 目录习惯。替换整栈成本高，故记录为本决策。
