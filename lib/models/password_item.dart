import 'package:flutter/material.dart';

/// 密码条目模型
class PasswordItem {
  final int? id;
  final String title;
  final String username;
  final String password;
  final String? website;
  final String? notes;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  PasswordItem({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    this.category = '其他',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从数据库Map创建对象
  factory PasswordItem.fromMap(Map<String, dynamic> map) {
    return PasswordItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      website: map['website'] as String?,
      notes: map['notes'] as String?,
      category: map['category'] as String? ?? '其他',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isFavorite: (map['is_favorite'] as int?) == 1,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// 复制并修改
  PasswordItem copyWith({
    int? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// 获取分类图标
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case '社交':
        return Icons.forum_outlined;
      case '购物':
        return Icons.shopping_bag_outlined;
      case '银行':
        return Icons.account_balance_outlined;
      case '邮箱':
        return Icons.mail_outlined;
      case '游戏':
        return Icons.sports_esports_outlined;
      case '工作':
        return Icons.work_outline;
      default:
        return Icons.key_outlined;
    }
  }

  /// 获取分类颜色
  static Color getCategoryColor(String category) {
    switch (category) {
      case '社交':
        return const Color(0xFF5865F2);
      case '购物':
        return const Color(0xFFE91E63);
      case '银行':
        return const Color(0xFF4CAF50);
      case '邮箱':
        return const Color(0xFFFF9800);
      case '游戏':
        return const Color(0xFF9C27B0);
      case '工作':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  /// 所有分类
  static List<String> get categories => [
        '社交',
        '购物',
        '银行',
        '邮箱',
        '游戏',
        '工作',
        '其他',
      ];
}
