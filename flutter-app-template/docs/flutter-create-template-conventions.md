# 模板源布局与消费约定

本文固化 **模板源**（`template/`）的目录约定与核对方式，供后续票写入工程文件时遵守。

## 原则

1. **唯一蓝本**：只维护 `template/`；禁止再维护第二份长期手改的「示例 App」。
2. **双端**：模板源只承诺 iOS + Android（可用 `--platforms=ios,android` 约束）。
3. **CLI 现实**：当前 Flutter（3.x）`flutter create -t` 的 `-t/--template` **只接受内置类型**（`app`、`module`、`package`、…），**不能**传入本仓路径。因此「自定义 template」在本仓落地为：
   - 把完整（或渐进完整）的 Flutter 工程放在 `template/`；
   - 用 `scripts/` 下的 create 脚本（后续票）复制/替换生成**模板实例**；
   - 必要时对生成目录执行 `flutter create --platforms=ios,android .` 做平台文件修复。

## 模板源目标布局（后续票逐步填满）

`template/` 最终应像一个普通 Flutter App 工程根，至少包含：

| 路径 | 说明 |
|------|------|
| `pubspec.yaml` | 包名占位；依赖由后续票加入 |
| `lib/` | Dart 入口与 feature 代码 |
| `android/` | Android 工程（含日后 `dev`/`prod` 变体） |
| `ios/` | iOS 工程（含日后变体） |
| `analysis_options.yaml` | 分析选项（后续加严） |
| `test/` | 单测（运维端口等） |

**不要**在 `template/` 使用 Flutter SDK 内部的 `*.tmpl` mustache 格式（那是 SDK 私有模板机制，不是本仓消费路径）。

## 消费（目标命令形态，脚本票实现）

```bash
# 仓库根目录执行（脚本名以后续票为准）
./scripts/create_from_template.sh <output_dir> --project-name <name> --org <org>
```

生成结果为独立的**模板实例**目录，可再自行接入 Firebase / 应用实例身份等。

## 核对命令

在仓库根执行：

```bash
./scripts/verify_template_layout.sh
./scripts/verify_template_layout.sh --strict
```

自票 07 起，`template/` 已具备最小双端 Flutter 工程；`--strict` 应通过。后续票继续往该蓝本叠加能力（GetX、构建变体等）。

## 与 ADR

见 [adr/0002-flutter-create-custom-template.md](./adr/0002-flutter-create-custom-template.md)。
