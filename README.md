# 逗号替换器 (Comma Replacer)

一个macOS应用程序，监听剪切板并自动将中文逗号替换为英文逗号，在粘贴时提供选择。

## 功能特性

- 🔍 实时监听剪切板变化
- 🔄 自动检测中文标点符号
- 🎯 粘贴时选择原文或替换后文本
- 🎨 简洁美观的SwiftUI界面
- 🚀 状态栏常驻应用

## 技术栈

- **SwiftUI** - 现代化UI框架
- **AppKit** - 剪切板操作
- **Foundation** - 字符串处理

## 系统要求

- macOS 12.0 (Monterey) 或更高版本
- Xcode 14.0 或更高版本

## 安装与编译

### 方式一：使用 Swift Package Manager

1. 克隆项目：
```bash
git clone [项目地址]
cd copy_replacer
```

2. 编译项目：
```bash
swift build -c release
```

3. 运行应用程序：
```bash
./.build/release/CommaReplacer
```

### 方式二：使用 Xcode

1. 打开项目：
```bash
open Package.swift
```

2. 在Xcode中：
   - 选择目标设备为 "My Mac"
   - 按 Cmd+R 运行

## 项目结构

```
Sources/CommaReplacer/
├── CommaReplacerApp.swift      # 主应用程序
├── ClipboardManager.swift         # 剪切板管理器
├── TextProcessor.swift            # 文本处理器
├── AppMenuView.swift               # 应用菜单视图
└── PasteDialogView.swift           # 粘贴对话框视图
```

## 核心类说明

### ClipboardManager
- 负责监听剪切板变化
- 管理粘贴对话框显示
- 处理文本替换逻辑

## 配置选项

应用程序提供以下配置：
- 启用/禁用剪切板监听
- 自定义标点符号替换规则

## 使用说明

1. 启动应用程序后，会在状态栏显示图标
2. 复制包含中文逗号的文本
3. 粘贴时会弹出选择对话框
4. 选择"粘贴原文"或"粘贴替换后文本"

## 开发指南

### 添加新的标点符号替换

在 `TextProcessor.swift` 中添加新的替换规则：

```swift
result = result.replacingOccurrences(of: "中文符号", with: "英文符号")
```

### 常见问题

**Q: 应用程序没有出现在状态栏？**
A: 确保应用程序有权限访问剪切板。在系统偏好设置 > 安全性与隐私 > 隐私 > 辅助功能中授权。

**Q: 如何开机自启动？**
A: 在系统偏好设置 > 用户与群组 > 登录项中添加应用程序。

## 许可证

MIT License 
