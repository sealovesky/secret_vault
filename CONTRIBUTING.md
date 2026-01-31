# Contributing

感谢你对 Secret Vault 的关注！欢迎通过以下方式参与贡献。

## 如何贡献

### 报告 Bug

1. 在 [Issues](../../issues) 中搜索是否已有相同问题
2. 如果没有，创建新 Issue，包含：
   - 问题描述
   - 复现步骤
   - 期望行为
   - 设备/系统信息
   - 截图（如适用）

### 提交功能建议

在 Issues 中创建 Feature Request，描述你希望添加的功能和使用场景。

### 提交代码

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m 'Add your feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 创建 Pull Request

### 代码规范

- 运行 `flutter analyze` 确保无错误和警告
- 运行 `flutter test` 确保所有测试通过
- 遵循 Dart 官方代码风格
- 为新功能编写测试
- 安全相关的更改需要特别审查

### 开发环境

```bash
# 安装依赖
flutter pub get

# 生成本地化文件
flutter gen-l10n

# 运行分析
flutter analyze

# 运行测试
flutter test
```

## 安全相关

涉及加密、认证、数据存储的更改需要额外注意：

- 不要降低加密强度
- 不要引入硬编码密钥
- 确保向后兼容已有数据
- 安全漏洞请私下报告，参见 [SECURITY.md](SECURITY.md)
