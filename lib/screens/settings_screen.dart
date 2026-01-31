import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../services/locale_provider.dart';
import '../services/vault_provider.dart';
import 'pin_setup_screen.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                l10n.settings,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.secondary.withValues(alpha:0.1),
                      colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // 安全设置
                _SectionHeader(title: l10n.security, icon: Icons.security_outlined),
                _SettingsTile(
                  icon: Icons.pin_outlined,
                  title: l10n.pinManagement,
                  subtitle: l10n.setOrChangePin,
                  onTap: () => _managePinCode(context),
                ),

                const SizedBox(height: 16),

                // 通用
                _SectionHeader(title: l10n.language, icon: Icons.language_outlined),
                _LanguageTile(),

                const SizedBox(height: 16),

                // 数据管理
                _SectionHeader(title: l10n.dataManagement, icon: Icons.folder_outlined),
                _SettingsTile(
                  icon: Icons.upload_outlined,
                  title: l10n.exportBackup,
                  subtitle: l10n.exportBackupDesc,
                  onTap: () => _exportBackup(context),
                ),
                _SettingsTile(
                  icon: Icons.download_outlined,
                  title: l10n.importBackup,
                  subtitle: l10n.importBackupDesc,
                  onTap: () => _importBackup(context),
                ),

                const SizedBox(height: 16),

                // 关于
                _SectionHeader(title: l10n.about, icon: Icons.info_outlined),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: l10n.appTitle,
                  subtitle: l10n.version('1.0.0'),
                  onTap: () => _showAbout(context),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.shield_outlined,
          size: 32,
          color: colorScheme.primary,
        ),
      ),
      applicationLegalese: l10n.allDataLocal,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.aboutDesc,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _managePinCode(BuildContext context) async {
    final authService = context.read<AuthService>();
    final hasPin = await authService.hasPinCode();

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (hasPin) {
      // 已有 PIN，显示选项
      final action = await showModalBottomSheet<String>(
        context: context,
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.edit, color: colorScheme.primary),
                  title: Text(l10n.changePinCode),
                  onTap: () => Navigator.pop(context, 'change'),
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(l10n.clearPinCode, style: TextStyle(color: colorScheme.error)),
                  onTap: () => Navigator.pop(context, 'clear'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );

      if (!context.mounted) return;

      if (action == 'change') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinSetupScreen(
              onPinSet: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.pinUpdated)),
                );
              },
            ),
          ),
        );
      } else if (action == 'clear') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.clearPinCode),
            content: Text(l10n.clearPinConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(l10n.clear),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await authService.clearPinCode();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pinCleared)),
            );
          }
        }
      }
    } else {
      // 没有 PIN，直接设置
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinSetupScreen(
            onPinSet: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pinSetSuccess)),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _exportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final password = await _showPasswordDialog(
      context,
      title: l10n.setBackupPassword,
      hint: l10n.backupPasswordHint,
      confirmPassword: true,
    );

    if (password == null || !context.mounted) return;

    // 显示加载
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final filePath = await BackupService.exportBackup(password);

      if (!context.mounted) return;
      Navigator.pop(context); // 关闭加载

      // 分享文件
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: l10n.backupSubject,
      );

      // 删除临时文件
      try {
        await File(filePath).delete();
      } catch (_) {}
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportFailed(e.toString()))),
      );
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    // 选择文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty || !context.mounted) return;

    final filePath = result.files.first.path;
    if (filePath == null) return;

    final l10n = AppLocalizations.of(context)!;

    // 输入密码
    final password = await _showPasswordDialog(
      context,
      title: l10n.enterBackupPassword,
      hint: l10n.backupPasswordInputHint,
    );

    if (password == null || !context.mounted) return;

    // 选择模式
    final merge = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importMethod),
        content: Text(l10n.chooseImportMethod),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.mergeKeepExisting),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.overwriteClearFirst),
          ),
        ],
      ),
    );

    if (merge == null || !context.mounted) return;

    // 显示加载
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final stats = await BackupService.importBackup(
        filePath,
        password,
        merge: merge,
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      // 刷新数据
      context.read<VaultProvider>().loadAll();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.importSuccess(stats['passwords'] as int, stats['notes'] as int),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importFailed(e.toString()))),
      );
    }
  }

  Future<String?> _showPasswordDialog(
    BuildContext context, {
    required String title,
    required String hint,
    bool confirmPassword = false,
  }) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    bool obscure = true;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(hint, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                ),
                if (confirmPassword) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPasswordLabel,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final pwd = controller.text;
                  if (pwd.isEmpty) return;
                  if (confirmPassword && pwd != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.passwordMismatch)),
                    );
                    return;
                  }
                  Navigator.pop(context, pwd);
                },
                child: Text(l10n.confirm),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha:0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 22),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final localeProvider = context.watch<LocaleProvider>();

    String currentLabel;
    final locale = localeProvider.locale;
    if (locale == null) {
      currentLabel = l10n.followSystem;
    } else if (locale.languageCode == 'zh') {
      currentLabel = l10n.chinese;
    } else {
      currentLabel = l10n.english;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.translate, color: colorScheme.primary, size: 22),
      ),
      title: Text(l10n.language),
      subtitle: Text(currentLabel),
      trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
      onTap: () => _showLanguagePicker(context),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();
    final currentCode = localeProvider.locale?.languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: Text(l10n.followSystem),
                trailing: currentCode == null
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  localeProvider.setLocale(null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('中', style: TextStyle(fontSize: 20)),
                title: Text(l10n.chinese),
                trailing: currentCode == 'zh'
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('zh'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('En', style: TextStyle(fontSize: 20)),
                title: Text(l10n.english),
                trailing: currentCode == 'en'
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
