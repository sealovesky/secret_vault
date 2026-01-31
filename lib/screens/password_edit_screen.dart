import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/password_item.dart';
import '../services/encryption_service.dart';
import '../services/vault_provider.dart';

/// 密码编辑页面
class PasswordEditScreen extends StatefulWidget {
  final PasswordItem? item;

  const PasswordEditScreen({super.key, this.item});

  @override
  State<PasswordEditScreen> createState() => _PasswordEditScreenState();
}

class _PasswordEditScreenState extends State<PasswordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _websiteController;
  late TextEditingController _notesController;

  String _selectedCategory = '其他';
  bool _showPassword = false;
  bool _isSaving = false;
  int _passwordStrength = 0;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _usernameController =
        TextEditingController(text: widget.item?.username ?? '');
    _passwordController =
        TextEditingController(text: widget.item?.password ?? '');
    _websiteController =
        TextEditingController(text: widget.item?.website ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedCategory = widget.item?.category ?? '其他';

    _passwordController.addListener(_updatePasswordStrength);
    _updatePasswordStrength();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength =
          EncryptionService.evaluatePasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editPasswordTitle : l10n.addPassword),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 标题
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.titleLabel,
                hintText: l10n.titleHint,
                prefixIcon: const Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.titleRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 用户名
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.usernameLabel,
                hintText: l10n.usernameHint,
                prefixIcon: const Icon(Icons.person),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.usernameRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 密码
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: l10n.password,
                hintText: l10n.passwordHint,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome),
                      tooltip: l10n.generatePassword,
                      onPressed: _generatePassword,
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.passwordRequired;
                }
                return null;
              },
            ),

            // 密码强度指示器
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PasswordStrengthIndicator(strength: _passwordStrength),
            ],

            const SizedBox(height: 16),

            // 分类选择
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.categoryLabel,
                prefixIcon: const Icon(Icons.category),
              ),
              items: PasswordItem.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: PasswordItem.getCategoryColor(category),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          PasswordItem.getCategoryIcon(category),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_localizeCategory(l10n, category)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // 网站
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: l10n.websiteOptional,
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // 备注
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notesOptional,
                hintText: l10n.notesHint,
                prefixIcon: const Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _generatePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PasswordGeneratorSheet(
        onGenerated: (password) {
          _passwordController.text = password;
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<VaultProvider>();

      final item = PasswordItem(
        id: widget.item?.id,
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        category: _selectedCategory,
        createdAt: widget.item?.createdAt,
        isFavorite: widget.item?.isFavorite ?? false,
      );

      if (_isEditing) {
        await provider.updatePassword(item);
      } else {
        await provider.addPassword(item);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? l10n.updated : l10n.saved)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// 密码强度指示器
class _PasswordStrengthIndicator extends StatelessWidget {
  final int strength;

  const _PasswordStrengthIndicator({required this.strength});

  static String _getStrengthText(BuildContext context, int strength) {
    final l10n = AppLocalizations.of(context)!;
    switch (strength) {
      case 0: return l10n.veryWeak;
      case 1: return l10n.weak;
      case 2: return l10n.medium;
      case 3: return l10n.strong;
      case 4: return l10n.veryStrong;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(EncryptionService.getPasswordStrengthColor(strength));
    final text = _getStrengthText(context, strength);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (strength + 1) / 5,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 密码生成器底部弹窗
class _PasswordGeneratorSheet extends StatefulWidget {
  final ValueChanged<String> onGenerated;

  const _PasswordGeneratorSheet({required this.onGenerated});

  @override
  State<_PasswordGeneratorSheet> createState() =>
      _PasswordGeneratorSheetState();
}

class _PasswordGeneratorSheetState extends State<_PasswordGeneratorSheet> {
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _generatedPassword = EncryptionService.generatePassword(
        length: _length.toInt(),
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strength =
        EncryptionService.evaluatePasswordStrength(_generatedPassword);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.passwordGenerator,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // 生成的密码
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _generatedPassword,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _generate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _PasswordStrengthIndicator(strength: strength),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 长度滑块
              Row(
                children: [
                  Text(l10n.length),
                  Expanded(
                    child: Slider(
                      value: _length,
                      min: 8,
                      max: 32,
                      divisions: 24,
                      label: _length.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          _length = value;
                        });
                        _generate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      _length.toInt().toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              // 选项
              CheckboxListTile(
                title: Text(l10n.includeUppercase),
                value: _includeUppercase,
                onChanged: (value) {
                  setState(() {
                    _includeUppercase = value ?? true;
                  });
                  _generate();
                },
              ),
              CheckboxListTile(
                title: Text(l10n.includeLowercase),
                value: _includeLowercase,
                onChanged: (value) {
                  setState(() {
                    _includeLowercase = value ?? true;
                  });
                  _generate();
                },
              ),
              CheckboxListTile(
                title: Text(l10n.includeNumbers),
                value: _includeNumbers,
                onChanged: (value) {
                  setState(() {
                    _includeNumbers = value ?? true;
                  });
                  _generate();
                },
              ),
              CheckboxListTile(
                title: Text(l10n.includeSymbols),
                value: _includeSymbols,
                onChanged: (value) {
                  setState(() {
                    _includeSymbols = value ?? true;
                  });
                  _generate();
                },
              ),

              const SizedBox(height: 16),

              // 使用按钮
              FilledButton(
                onPressed: () => widget.onGenerated(_generatedPassword),
                child: Text(l10n.useThisPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分类名本地化映射
String _localizeCategory(AppLocalizations l10n, String category) {
  switch (category) {
    case '社交': return l10n.categorySocial;
    case '购物': return l10n.categoryShopping;
    case '银行': return l10n.categoryBanking;
    case '邮箱': return l10n.categoryEmail;
    case '游戏': return l10n.categoryGaming;
    case '工作': return l10n.categoryWork;
    case '其他': return l10n.categoryOther;
    default: return category;
  }
}
