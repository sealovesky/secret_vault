# Secret Vault

Secret Vault (私密保险箱) 是一款注重隐私的本地密码管理器与私密笔记应用，基于 Flutter 构建，所有数据均在设备本地加密存储。

## 功能特性

- **密码管理** - 安全存储网站/应用的账号密码，支持分类、收藏、搜索
- **私密笔记** - 加密笔记本，支持多彩背景、置顶、网格/列表视图切换
- **生物识别** - 支持指纹/面容 ID 解锁，兼容 PIN 码备用认证
- **密码生成器** - 可配置长度和字符类型的安全随机密码生成
- **密码强度评估** - 实时评估密码安全等级
- **加密备份** - 导出/导入加密备份文件 (.svault)，支持合并或覆盖导入
- **隐私保护** - 切换到后台时自动模糊遮罩，防止多任务预览泄露
- **多语言** - 支持中文和英文

## 安全架构

| 组件 | 实现 |
|------|------|
| 数据加密 | AES-256-CBC + 随机 IV + HMAC-SHA256 完整性校验 |
| 密钥管理 | 随机生成 32 字节密钥，存储于系统 Keychain/Keystore |
| PIN 码 | SHA-256 + 随机盐值哈希存储 |
| 备份加密 | 用户密码 + 随机盐值派生密钥 (100,000 轮 HMAC-SHA256) |
| 认证 | 系统生物识别 API (local_auth) |

> 所有敏感数据仅在本地设备存储和处理，不会上传到任何服务器。

## 快速开始

### 环境要求

- Flutter 3.0+
- Dart 3.0+
- Android SDK 21+ / iOS 12+

### 安装与运行

```bash
# 克隆项目
git clone https://github.com/sealovesky/secret_vault.git
cd secret_vault

# 安装依赖
flutter pub get

# 生成本地化文件
flutter gen-l10n

# 运行
flutter run
```

### 运行测试

```bash
flutter test
```

### 构建发布版本

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 技术栈

- **框架**: Flutter + Dart
- **状态管理**: Provider
- **本地数据库**: sqflite
- **加密**: encrypt (AES) + crypto (HMAC-SHA256)
- **安全存储**: flutter_secure_storage
- **认证**: local_auth
- **国际化**: Flutter gen-l10n (ARB)

## 项目结构

```
lib/
├── main.dart              # 应用入口、主题配置、认证入口
├── l10n/                  # 国际化资源
├── models/                # 数据模型
│   ├── password_item.dart
│   └── note_item.dart
├── screens/               # 页面
│   ├── home_screen.dart
│   ├── lock_screen.dart
│   ├── passwords_screen.dart
│   ├── password_edit_screen.dart
│   ├── notes_screen.dart
│   ├── note_edit_screen.dart
│   ├── pin_setup_screen.dart
│   └── settings_screen.dart
├── services/              # 业务服务
│   ├── auth_service.dart
│   ├── backup_service.dart
│   ├── database_service.dart
│   ├── encryption_service.dart
│   └── vault_provider.dart
└── utils/
    └── app_logger.dart
```

## 许可证

本项目基于 [MIT License](LICENSE) 开源。

## 安全问题

如果你发现安全漏洞，请参阅 [SECURITY.md](SECURITY.md) 了解报告流程。

## 贡献

欢迎贡献代码！请参阅 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。
