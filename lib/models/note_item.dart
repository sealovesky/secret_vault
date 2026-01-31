/// 私密笔记模型
class NoteItem {
  final int? id;
  final String title;
  final String content;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  NoteItem({
    this.id,
    required this.title,
    required this.content,
    this.color = 'default',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从数据库Map创建对象
  factory NoteItem.fromMap(Map<String, dynamic> map) {
    return NoteItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      color: map['color'] as String? ?? 'default',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isPinned: (map['is_pinned'] as int?) == 1,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  /// 复制并修改
  NoteItem copyWith({
    int? id,
    String? title,
    String? content,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// 获取颜色值
  static int getColorValue(String colorName) {
    switch (colorName) {
      case 'red':
        return 0xFFFFCDD2;
      case 'pink':
        return 0xFFF8BBD9;
      case 'purple':
        return 0xFFE1BEE7;
      case 'blue':
        return 0xFFBBDEFB;
      case 'cyan':
        return 0xFFB2EBF2;
      case 'green':
        return 0xFFC8E6C9;
      case 'yellow':
        return 0xFFFFF9C4;
      case 'orange':
        return 0xFFFFE0B2;
      default:
        return 0xFFF5F5F5;
    }
  }

  /// 所有颜色选项
  static List<String> get colors => [
        'default',
        'red',
        'pink',
        'purple',
        'blue',
        'cyan',
        'green',
        'yellow',
        'orange',
      ];

  /// 获取预览文本（前100字）
  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// 格式化时间显示（保留用于非本地化场景）
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${updatedAt.month}月${updatedAt.day}日';
    }
  }

  /// 本地化时间格式 - 需传入本地化函数
  String localizedDate({
    required String Function() justNow,
    required String Function(int count) minutesAgo,
    required String Function(int count) hoursAgo,
    required String Function(int count) daysAgo,
    required String Function(int month, int day) monthDay,
  }) {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inMinutes < 1) {
      return justNow();
    } else if (diff.inHours < 1) {
      return minutesAgo(diff.inMinutes);
    } else if (diff.inDays < 1) {
      return hoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return daysAgo(diff.inDays);
    } else {
      return monthDay(updatedAt.month, updatedAt.day);
    }
  }
}
