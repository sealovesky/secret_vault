import 'package:flutter_test/flutter_test.dart';
import 'package:secret_vault/models/password_item.dart';

void main() {
  group('PasswordItem', () {
    group('构造函数', () {
      test('必填字段正确赋值', () {
        final item = PasswordItem(
          title: '测试',
          username: 'user',
          password: 'pass',
        );
        expect(item.title, equals('测试'));
        expect(item.username, equals('user'));
        expect(item.password, equals('pass'));
        expect(item.category, equals('其他'));
        expect(item.isFavorite, isFalse);
        expect(item.id, isNull);
        expect(item.website, isNull);
        expect(item.notes, isNull);
      });

      test('可选字段正确赋值', () {
        final now = DateTime.now();
        final item = PasswordItem(
          id: 1,
          title: '测试',
          username: 'user',
          password: 'pass',
          website: 'https://example.com',
          notes: '备注',
          category: '社交',
          createdAt: now,
          updatedAt: now,
          isFavorite: true,
        );
        expect(item.id, equals(1));
        expect(item.website, equals('https://example.com'));
        expect(item.notes, equals('备注'));
        expect(item.category, equals('社交'));
        expect(item.isFavorite, isTrue);
        expect(item.createdAt, equals(now));
      });

      test('默认时间为当前时间', () {
        final before = DateTime.now();
        final item = PasswordItem(
          title: '测试',
          username: 'user',
          password: 'pass',
        );
        final after = DateTime.now();
        expect(item.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(item.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('fromMap / toMap', () {
      test('往返转换保持数据一致', () {
        final now = DateTime.now();
        final original = PasswordItem(
          id: 42,
          title: '微信',
          username: 'wechat_user',
          password: 'secure_password',
          website: 'https://weixin.qq.com',
          notes: '工作微信',
          category: '社交',
          createdAt: now,
          updatedAt: now,
          isFavorite: true,
        );

        final map = original.toMap();
        final restored = PasswordItem.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.title, equals(original.title));
        expect(restored.username, equals(original.username));
        expect(restored.password, equals(original.password));
        expect(restored.website, equals(original.website));
        expect(restored.notes, equals(original.notes));
        expect(restored.category, equals(original.category));
        expect(restored.isFavorite, equals(original.isFavorite));
      });

      test('toMap 无 id 时不包含 id 字段', () {
        final item = PasswordItem(
          title: '测试',
          username: 'user',
          password: 'pass',
        );
        final map = item.toMap();
        expect(map.containsKey('id'), isFalse);
      });

      test('fromMap 处理 null category', () {
        final map = {
          'id': 1,
          'title': '测试',
          'username': 'user',
          'password': 'pass',
          'website': null,
          'notes': null,
          'category': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_favorite': 0,
        };
        final item = PasswordItem.fromMap(map);
        expect(item.category, equals('其他'));
      });

      test('fromMap 处理 is_favorite 为 0 和 1', () {
        final map = {
          'id': 1,
          'title': '测试',
          'username': 'user',
          'password': 'pass',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_favorite': 1,
        };
        expect(PasswordItem.fromMap(map).isFavorite, isTrue);

        map['is_favorite'] = 0;
        expect(PasswordItem.fromMap(map).isFavorite, isFalse);
      });
    });

    group('copyWith', () {
      test('修改指定字段保留其他字段', () {
        final original = PasswordItem(
          id: 1,
          title: '原标题',
          username: '原用户名',
          password: '原密码',
          category: '社交',
          isFavorite: false,
        );

        final modified = original.copyWith(
          title: '新标题',
          isFavorite: true,
        );

        expect(modified.title, equals('新标题'));
        expect(modified.isFavorite, isTrue);
        // 未修改的字段保持不变
        expect(modified.id, equals(1));
        expect(modified.username, equals('原用户名'));
        expect(modified.password, equals('原密码'));
        expect(modified.category, equals('社交'));
      });

      test('copyWith 自动更新 updatedAt', () {
        final original = PasswordItem(
          title: '测试',
          username: 'user',
          password: 'pass',
          updatedAt: DateTime(2020, 1, 1),
        );

        final modified = original.copyWith(title: '新标题');
        expect(modified.updatedAt.isAfter(original.updatedAt), isTrue);
      });
    });

    group('getCategoryIcon / getCategoryColor', () {
      test('所有分类都有图标', () {
        for (final category in PasswordItem.categories) {
          final icon = PasswordItem.getCategoryIcon(category);
          expect(icon, isNotNull);
        }
      });

      test('所有分类都有颜色', () {
        for (final category in PasswordItem.categories) {
          final color = PasswordItem.getCategoryColor(category);
          expect(color, isNotNull);
        }
      });

      test('未知分类返回默认值', () {
        final icon = PasswordItem.getCategoryIcon('不存在的分类');
        expect(icon, isNotNull);
        final color = PasswordItem.getCategoryColor('不存在的分类');
        expect(color, isNotNull);
      });
    });

    group('categories', () {
      test('包含预期分类', () {
        expect(PasswordItem.categories, contains('社交'));
        expect(PasswordItem.categories, contains('购物'));
        expect(PasswordItem.categories, contains('银行'));
        expect(PasswordItem.categories, contains('邮箱'));
        expect(PasswordItem.categories, contains('游戏'));
        expect(PasswordItem.categories, contains('工作'));
        expect(PasswordItem.categories, contains('其他'));
        expect(PasswordItem.categories.length, equals(7));
      });
    });
  });
}
