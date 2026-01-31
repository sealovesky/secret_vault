# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a Vulnerability

如果你发现了安全漏洞，请**不要**在公开的 Issue 中报告。

请通过以下方式私下报告：

1. 发送邮件至项目维护者（请在 GitHub 仓库页面查看联系方式）
2. 或通过 GitHub 的 [Security Advisory](../../security/advisories/new) 功能提交

### 报告内容

请在报告中包含：

- 漏洞描述
- 复现步骤
- 影响范围
- 可能的修复建议（如有）

### 响应时间

- 我们会在 **48 小时**内确认收到报告
- 在 **7 天**内提供初步评估
- 修复后会在 CHANGELOG 中致谢（除非你希望匿名）

## Security Design

Secret Vault 的安全设计：

- 所有敏感数据使用 AES-256-CBC 加密，配合随机 IV 和 HMAC-SHA256 完整性校验
- 加密密钥由系统安全存储管理（iOS Keychain / Android Keystore）
- PIN 码使用 SHA-256 + 随机盐值哈希存储
- 备份文件使用用户密码派生密钥加密（100,000 轮 HMAC-SHA256）
- 所有数据仅在本地存储，不进行网络传输
