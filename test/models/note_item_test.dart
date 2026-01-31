import 'package:flutter_test/flutter_test.dart';
import 'package:secret_vault/models/note_item.dart';

void main() {
  group('NoteItem', () {
    group('构造函数', () {
      test('必填字段正确赋值', () {
        final item = NoteItem(
          title: '测试笔记',
          content: '笔记内容',
        );
        expect(item.title, equals('测试笔记'));
        expect(item.content, equals('笔记内容'));
        expect(item.color, equals('default'));
        expect(item.isPinned, isFalse);
        expect(item.id, isNull);
      });

      test('可选字段正确赋值', () {
        final now = DateTime.now();
        final item = NoteItem(
          id: 1,
          title: '测试笔记',
          content: '笔记内容',
          color: 'red',
          createdAt: now,
          updatedAt: now,
          isPinned: true,
        );
        expect(item.id, equals(1));
        expect(item.color, equals('red'));
        expect(item.isPinned, isTrue);
        expect(item.createdAt, equals(now));
      });
    });

    group('fromMap / toMap', () {
      test('往返转换保持数据一致', () {
        final now = DateTime.now();
        final original = NoteItem(
          id: 42,
          title: '重要笔记',
          content: '这是一段很长的笔记内容，用于测试数据的完整性保持。',
          color: 'purple',
          createdAt: now,
          updatedAt: now,
          isPinned: true,
        );

        final map = original.toMap();
        final restored = NoteItem.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.content, equals(original.content));
        expect(restored.color, equals(original.color));
        expect(restored.isPinned, equals(original.isPinned));
      });

      test('toMap 无 id 时不包含 id 字段', () {
        final item = NoteItem(title: '测试', content: '内容');
        final map = item.toMap();
        expect(map.containsKey('id'), isFalse);
      });

      test('fromMap 处理 null color', () {
        final map = {
          'id': 1,
          'title': '测试',
          'content': '内容',
          'color': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_pinned': 0,
        };
        final item = NoteItem.fromMap(map);
        expect(item.color, equals('default'));
      });

      test('fromMap 处理 is_pinned 为 0 和 1', () {
        final map = {
          'id': 1,
          'title': '测试',
          'content': '内容',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_pinned': 1,
        };
        expect(NoteItem.fromMap(map).isPinned, isTrue);

        map['is_pinned'] = 0;
        expect(NoteItem.fromMap(map).isPinned, isFalse);
      });
    });

    group('copyWith', () {
      test('修改指定字段保留其他字段', () {
        final original = NoteItem(
          id: 1,
          title: '原标题',
          content: '原内容',
          color: 'blue',
          isPinned: false,
        );

        final modified = original.copyWith(
          title: '新标题',
          isPinned: true,
        );

        expect(modified.title, equals('新标题'));
        expect(modified.isPinned, isTrue);
        expect(modified.id, equals(1));
        expect(modified.content, equals('原内容'));
        expect(modified.color, equals('blue'));
      });

      test('copyWith 自动更新 updatedAt', () {
        final original = NoteItem(
          title: '测试',
          content: '内容',
          updatedAt: DateTime(2020, 1, 1),
        );

        final modified = original.copyWith(title: '新标题');
        expect(modified.updatedAt.isAfter(original.updatedAt), isTrue);
      });
    });

    group('getColorValue', () {
      test('所有颜色选项返回有效值', () {
        for (final color in NoteItem.colors) {
          final value = NoteItem.getColorValue(color);
          expect(value, isNotNull);
          expect(value, greaterThan(0));
        }
      });

      test('default 返回灰色', () {
        expect(NoteItem.getColorValue('default'), equals(0xFFF5F5F5));
      });

      test('未知颜色返回默认灰色', () {
        expect(NoteItem.getColorValue('不存在'), equals(0xFFF5F5F5));
      });
    });

    group('colors', () {
      test('包含预期颜色', () {
        expect(NoteItem.colors, contains('default'));
        expect(NoteItem.colors, contains('red'));
        expect(NoteItem.colors, contains('blue'));
        expect(NoteItem.colors, contains('green'));
        expect(NoteItem.colors.length, equals(9));
      });
    });

    group('preview', () {
      test('短内容返回全部', () {
        final item = NoteItem(title: '测试', content: '短内容');
        expect(item.preview, equals('短内容'));
      });

      test('长内容截断到 100 字', () {
        final longContent = 'A' * 200;
        final item = NoteItem(title: '测试', content: longContent);
        expect(item.preview.length, equals(103)); // 100 + "..."
        expect(item.preview.endsWith('...'), isTrue);
      });

      test('恰好 100 字不截断', () {
        final content = 'A' * 100;
        final item = NoteItem(title: '测试', content: content);
        expect(item.preview, equals(content));
      });
    });

    group('formattedDate', () {
      test('刚刚', () {
        final item = NoteItem(
          title: '测试',
          content: '内容',
          updatedAt: DateTime.now(),
        );
        expect(item.formattedDate, equals('刚刚'));
      });

      test('分钟前', () {
        final item = NoteItem(
          title: '测试',
          content: '内容',
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        expect(item.formattedDate, equals('30分钟前'));
      });

      test('小时前', () {
        final item = NoteItem(
          title: '测试',
          content: '内容',
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        );
        expect(item.formattedDate, equals('3小时前'));
      });

      test('天前', () {
        final item = NoteItem(
          title: '测试',
          content: '内容',
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(item.formattedDate, equals('3天前'));
      });

      test('超过 7 天显示日期', () {
        final date = DateTime.now().subtract(const Duration(days: 10));
        final item = NoteItem(
          title: '测试',
          content: '内容',
          updatedAt: date,
        );
        expect(item.formattedDate, equals('${date.month}月${date.day}日'));
      });
    });
  });
}
