import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/password_item.dart';
import '../services/vault_provider.dart';
import 'password_edit_screen.dart';
import '../l10n/app_localizations.dart';

/// 密码列表页面
class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({super.key});

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSearching = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VaultProvider>().loadMorePasswords();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Consumer<VaultProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 自定义AppBar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: _isSearching
                      ? null
                      : Text(
                          l10n.passwordManagement,
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
                          colorScheme.primary.withValues(alpha:0.1),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (_isSearching)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: l10n.searchPasswords,
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                });
                                provider.setSearchQuery('');
                              },
                            ),
                          ),
                          onChanged: provider.setSearchQuery,
                        ),
                      ),
                    )
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),

              // 统计卡片
              if (!_isSearching)
                SliverToBoxAdapter(
                  child: _buildStatsCard(context, provider),
                ),

              // 分类筛选
              if (!_isSearching)
                SliverToBoxAdapter(
                  child: _buildCategoryFilter(context, provider),
                ),

              // 密码列表
              if (provider.passwords.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(context),
                )
              else ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = provider.passwords[index];
                      return _PasswordCard(
                        item: item,
                        onTap: () => _showPasswordDetail(context, item),
                        onEdit: () => _editPassword(context, item),
                        onDelete: () => _deletePassword(context, item),
                        onToggleFavorite: () =>
                            provider.togglePasswordFavorite(item),
                      );
                    },
                    childCount: provider.passwords.length,
                  ),
                ),
                if (provider.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addPassword',
        onPressed: () => _addPassword(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addPassword),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, VaultProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = provider.passwords.length;
    final favorites = provider.favoritePasswords.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha:0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha:0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.secureStorage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha:0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.nPasswords(total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$favorites',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, VaultProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryChip(
            label: l10n.all,
            icon: Icons.grid_view_rounded,
            isSelected: _selectedCategory == null,
            onTap: () {
              setState(() => _selectedCategory = null);
              provider.setCategory(null);
            },
          ),
          ...PasswordItem.categories.map((cat) => _CategoryChip(
                label: _localizeCategory(l10n, cat),
                icon: PasswordItem.getCategoryIcon(cat),
                isSelected: _selectedCategory == cat,
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  provider.setCategory(cat);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha:0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.key_off_outlined,
              size: 56,
              color: theme.colorScheme.primary.withValues(alpha:0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noPasswordsYet,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToAddPassword,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordDetail(BuildContext context, PasswordItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PasswordDetailSheet(item: item),
    );
  }

  void _addPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordEditScreen(),
      ),
    );
  }

  void _editPassword(BuildContext context, PasswordItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordEditScreen(item: item),
      ),
    );
  }

  Future<void> _deletePassword(BuildContext context, PasswordItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePasswordTitle),
        content: Text(l10n.deletePasswordConfirm(item.title)),
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
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<VaultProvider>().deletePassword(item.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleted)),
        );
      }
    }
  }
}

/// 分类筛选芯片
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.primary,
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
        ),
      ),
    );
  }
}

/// 密码卡片
class _PasswordCard extends StatelessWidget {
  final PasswordItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _PasswordCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.4,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit, size: 22),
                  const SizedBox(height: 4),
                  Text(l10n.edit, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            CustomSlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete, size: 22),
                  const SizedBox(height: 4),
                  Text(l10n.delete, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        child: Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          elevation: 1,
          shadowColor: colorScheme.shadow.withValues(alpha:0.1),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha:0.5),
                ),
              ),
              child: Row(
                children: [
                  // 图标
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          PasswordItem.getCategoryColor(item.category),
                          PasswordItem.getCategoryColor(item.category).withValues(alpha:0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      PasswordItem.getCategoryIcon(item.category),
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // 信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.isFavorite)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha:0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.username,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.website != null && item.website!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.website!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 复制按钮
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      color: colorScheme.primary,
                    ),
                    tooltip: l10n.copyPassword,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.password));
                      Future.delayed(const Duration(seconds: 30), () {
                        Clipboard.setData(const ClipboardData(text: ''));
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(l10n.passwordCopiedWithClear),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

/// 密码详情底部弹窗
class _PasswordDetailSheet extends StatefulWidget {
  final PasswordItem item;

  const _PasswordDetailSheet({required this.item});

  @override
  State<_PasswordDetailSheet> createState() => _PasswordDetailSheetState();
}

class _PasswordDetailSheetState extends State<_PasswordDetailSheet> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
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

              // 标题卡片
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withValues(alpha:0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: PasswordItem.getCategoryColor(item.category),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        PasswordItem.getCategoryIcon(item.category),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _localizeCategory(l10n, item.category),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: item.isFavorite ? Colors.amber : null,
                        size: 28,
                      ),
                      onPressed: () {
                        context
                            .read<VaultProvider>()
                            .togglePasswordFavorite(item);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 信息列表
              _DetailCard(
                icon: Icons.person_outline,
                label: l10n.username,
                value: item.username,
                onCopy: () => _copyToClipboard(context, item.username, l10n.username),
              ),

              const SizedBox(height: 12),

              _DetailCard(
                icon: Icons.lock_outline,
                label: l10n.password,
                value: _showPassword ? item.password : '••••••••••••',
                trailing: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                onCopy: () => _copyToClipboard(context, item.password, l10n.password),
              ),

              if (item.website != null && item.website!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailCard(
                  icon: Icons.language,
                  label: l10n.website,
                  value: item.website!,
                  onCopy: () =>
                      _copyToClipboard(context, item.website!, l10n.website),
                ),
              ],

              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailCard(
                  icon: Icons.note_outlined,
                  label: l10n.remark,
                  value: item.notes!,
                  isMultiline: true,
                ),
              ],

              const SizedBox(height: 24),

              // 底部信息
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.createdAt(_formatDate(context, item.createdAt)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    Future.delayed(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
    final isPassword = label == l10n.password;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(isPassword ? l10n.labelCopiedWithClear(label) : l10n.labelCopied(label)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.dateFormat(date.year, date.month, date.day);
  }
}

/// 详情卡片
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onCopy;
  final bool isMultiline;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onCopy,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha:0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
              if (onCopy != null)
                IconButton(
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  onPressed: onCopy,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ],
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
