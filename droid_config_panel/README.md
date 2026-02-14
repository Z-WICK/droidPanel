# Droid Config Panel

一个用于管理 Factory Droid 配置的 macOS 桌面应用。

## 功能

- 查看和管理 Droid、Skill、Hook、MCP Server 配置
- 支持 Personal (`~/.factory/`) 和 Project (`.factory/`) 两种配置范围
- 配置语法校验
- 搜索和筛选

## 截图

TODO

## 安装

### 从源码构建

需要 Flutter 3.x 和 Xcode。

```bash
cd droid_config_panel
flutter pub get
flutter build macos --release
```

构建产物在 `build/macos/Build/Products/Release/Droid Config Panel.app`

### 直接运行

双击项目根目录的 `Droid Config Panel.app` 快捷方式。

## 配置文件位置

| 类型 | Personal | Project |
|------|----------|---------|
| Droid | `~/.factory/droids/*.md` | `.factory/droids/*.md` |
| Skill | `~/.factory/skills/*/SKILL.md` | `.factory/skills/*/SKILL.md` |
| Hook | `~/.factory/hooks/hooks.json` | `.factory/hooks/hooks.json` |
| MCP Server | `~/.factory/mcp.json` | `.factory/mcp.json` |

## 技术栈

- Flutter Desktop (macOS)
- Riverpod 状态管理
- YAML/JSON 解析

## 测试

```bash
cd droid_config_panel
flutter analyze
flutter test
flutter test integration_test/configuration_flow_test.dart
```

- `flutter test`：服务层与状态管理单元测试
- `integration_test/configuration_flow_test.dart`：UI 端到端流程（创建、搜索、编辑、删除）

## License

MIT
