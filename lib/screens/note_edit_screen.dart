import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/note_item.dart';
import '../services/vault_provider.dart';

/// 笔记编辑页面
class NoteEditScreen extends StatefulWidget {
  final NoteItem? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _contentFocusNode;
  String _selectedColor = 'default';
  bool _isSaving = false;
  bool _hasChanges = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _contentFocusNode = FocusNode();
    _selectedColor = widget.note?.color ?? 'default';

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bgColor = Color(NoteItem.getColorValue(_selectedColor));
    final wordCount = _contentController.text.length;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha:0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _showDiscardDialog();
                if (shouldPop && context.mounted) {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            // 颜色选择
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha:0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
              onPressed: _showColorPicker,
            ),
            const SizedBox(width: 8),
            // 保存按钮
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(l10n.save),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 标题
                    TextField(
                      controller: _titleController,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.titleLabel,
                        hintStyle: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.outline.withValues(alpha:0.5),
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        _contentFocusNode.requestFocus();
                      },
                    ),

                    const SizedBox(height: 4),

                    // 信息栏
                    Row(
                      children: [
                        if (_isEditing) ...[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.note!.localizedDate(justNow: () => l10n.justNow, minutesAgo: l10n.minutesAgo, hoursAgo: l10n.hoursAgo, daysAgo: l10n.daysAgo, monthDay: l10n.monthDay),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorScheme.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        Text(
                          l10n.wordCount(wordCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 分隔线
                    Container(
                      height: 1,
                      color: colorScheme.outline.withValues(alpha:0.2),
                    ),

                    const SizedBox(height: 20),

                    // 内容
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.noteContentHint,
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.outline.withValues(alpha:0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // 底部工具栏
            _buildBottomToolbar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 12
            : MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha:0.95),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha:0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // 插入时间
          _ToolbarButton(
            icon: Icons.schedule,
            tooltip: l10n.insertTime,
            onTap: () {
              final now = DateTime.now();
              final timeStr =
                  '${now.year}/${now.month}/${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
              _insertText(timeStr);
            },
          ),
          const SizedBox(width: 8),

          // 插入分隔线
          _ToolbarButton(
            icon: Icons.horizontal_rule,
            tooltip: l10n.insertDivider,
            onTap: () {
              _insertText('\n─────────────────\n');
            },
          ),
          const SizedBox(width: 8),

          // 插入列表
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: l10n.insertList,
            onTap: () {
              _insertText('\n• ');
            },
          ),
          const SizedBox(width: 8),

          // 插入待办
          _ToolbarButton(
            icon: Icons.check_box_outlined,
            tooltip: l10n.insertTodo,
            onTap: () {
              _insertText('\n☐ ');
            },
          ),

          const Spacer(),

          // 键盘收起
          if (MediaQuery.of(context).viewInsets.bottom > 0)
            _ToolbarButton(
              icon: Icons.keyboard_hide,
              tooltip: l10n.hideKeyboard,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
            ),
        ],
      ),
    );
  }

  void _insertText(String text) {
    final selection = _contentController.selection;
    final currentText = _contentController.text;

    if (selection.isValid) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + text.length,
        ),
      );
    } else {
      _contentController.text = currentText + text;
      _contentController.selection = TextSelection.collapsed(
        offset: _contentController.text.length,
      );
    }

    _contentFocusNode.requestFocus();
  }

  void _showColorPicker() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  l10n.selectBackground,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.selectBackgroundDesc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),

                const SizedBox(height: 24),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: NoteItem.colors.map((colorName) {
                    final color = Color(NoteItem.getColorValue(colorName));
                    final isSelected = colorName == _selectedColor;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = colorName;
                          _hasChanges = true;
                        });
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(alpha:0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.discardChanges),
          content: Text(l10n.unsavedChanges),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.continueEditing),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.discard),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.enterContent),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<VaultProvider>();

      final note = NoteItem(
        id: widget.note?.id,
        title: title.isNotEmpty ? title : l10n.untitled,
        content: content,
        color: _selectedColor,
        createdAt: widget.note?.createdAt,
        isPinned: widget.note?.isPinned ?? false,
      );

      if (_isEditing) {
        await provider.updateNote(note);
      } else {
        await provider.addNote(note);
      }

      if (mounted) {
        _hasChanges = false;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(_isEditing ? l10n.updated : l10n.saved),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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

/// 工具栏按钮
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
