import 'package:flutter_test/flutter_test.dart';
import 'package:secret_vault/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService service;

    setUp(() {
      final key = EncryptionService.generateKey();
      service = EncryptionService(key);
    });

    group('encrypt / decrypt', () {
      test('正确加解密普通文本', () {
        const plainText = 'Hello, 世界！';
        final encrypted = service.encrypt(plainText);
        final decrypted = service.decrypt(encrypted);
        expect(decrypted, equals(plainText));
      });

      test('空字符串返回空字符串', () {
        expect(service.encrypt(''), equals(''));
        expect(service.decrypt(''), equals(''));
      });

      test('相同明文每次加密产生不同密文（随机 IV）', () {
        const plainText = 'same text';
        final encrypted1 = service.encrypt(plainText);
        final encrypted2 = service.encrypt(plainText);
        expect(encrypted1, isNot(equals(encrypted2)));
        // 但解密结果相同
        expect(service.decrypt(encrypted1), equals(plainText));
        expect(service.decrypt(encrypted2), equals(plainText));
      });

      test('长文本加解密', () {
        final longText = 'A' * 10000;
        final encrypted = service.encrypt(longText);
        final decrypted = service.decrypt(encrypted);
        expect(decrypted, equals(longText));
      });

      test('特殊字符加解密', () {
        const specialText = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';
        final encrypted = service.encrypt(specialText);
        final decrypted = service.decrypt(encrypted);
        expect(decrypted, equals(specialText));
      });

      test('Unicode 字符加解密', () {
        const unicodeText = '🔑🛡️🔒 密码管理器 パスワード';
        final encrypted = service.encrypt(unicodeText);
        final decrypted = service.decrypt(encrypted);
        expect(decrypted, equals(unicodeText));
      });
    });

    group('旧格式兼容', () {
      test('legacy 实例可以加解密', () {
        final legacy = EncryptionService.legacy();
        const plainText = '旧数据';
        // 新 encrypt 的数据可以被同密钥的 decrypt 解
        final newEncrypted = legacy.encrypt(plainText);
        expect(legacy.decrypt(newEncrypted), equals(plainText));
      });
    });

    group('generateKey', () {
      test('生成 32 字节密钥', () {
        final key = EncryptionService.generateKey();
        expect(key.bytes.length, equals(32));
      });

      test('每次生成不同密钥', () {
        final key1 = EncryptionService.generateKey();
        final key2 = EncryptionService.generateKey();
        expect(key1.bytes, isNot(equals(key2.bytes)));
      });
    });

    group('不同密钥隔离', () {
      test('不同密钥无法解密对方数据', () {
        final key1 = EncryptionService.generateKey();
        final key2 = EncryptionService.generateKey();
        final service1 = EncryptionService(key1);
        final service2 = EncryptionService(key2);

        const plainText = 'secret data';
        final encrypted = service1.encrypt(plainText);
        // service2 尝试解密，应返回原始密文（解密失败回退）
        final result = service2.decrypt(encrypted);
        expect(result, isNot(equals(plainText)));
      });
    });
  });

  group('generatePassword', () {
    test('默认参数生成 16 位密码', () {
      final password = EncryptionService.generatePassword();
      expect(password.length, equals(16));
    });

    test('指定长度', () {
      final password = EncryptionService.generatePassword(length: 24);
      expect(password.length, equals(24));
    });

    test('包含大写字母', () {
      final password = EncryptionService.generatePassword(
        length: 50,
        includeUppercase: true,
        includeLowercase: false,
        includeNumbers: false,
        includeSymbols: false,
      );
      expect(password, matches(RegExp(r'^[A-Z]+$')));
    });

    test('包含小写字母', () {
      final password = EncryptionService.generatePassword(
        length: 50,
        includeUppercase: false,
        includeLowercase: true,
        includeNumbers: false,
        includeSymbols: false,
      );
      expect(password, matches(RegExp(r'^[a-z]+$')));
    });

    test('包含数字', () {
      final password = EncryptionService.generatePassword(
        length: 50,
        includeUppercase: false,
        includeLowercase: false,
        includeNumbers: true,
        includeSymbols: false,
      );
      expect(password, matches(RegExp(r'^[0-9]+$')));
    });

    test('全类型密码包含所有字符类型', () {
      final password = EncryptionService.generatePassword(length: 50);
      expect(password, matches(RegExp(r'[A-Z]')));
      expect(password, matches(RegExp(r'[a-z]')));
      expect(password, matches(RegExp(r'[0-9]')));
      expect(password, matches(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]')));
    });

    test('每次生成不同密码', () {
      // 极低概率相同，但理论上可能。多生成几次降低误报
      final passwords = List.generate(10, (_) => EncryptionService.generatePassword());
      final unique = passwords.toSet();
      expect(unique.length, greaterThan(1));
    });

    test('所有选项关闭时回退到默认字符集', () {
      final password = EncryptionService.generatePassword(
        includeUppercase: false,
        includeLowercase: false,
        includeNumbers: false,
        includeSymbols: false,
      );
      expect(password.length, equals(16));
      expect(password, matches(RegExp(r'^[a-z0-9]+$')));
    });
  });

  group('evaluatePasswordStrength', () {
    test('空密码返回 0', () {
      expect(EncryptionService.evaluatePasswordStrength(''), equals(0));
    });

    test('短纯数字密码为非常弱', () {
      expect(EncryptionService.evaluatePasswordStrength('123'), equals(0));
    });

    test('8位纯小写为非常弱（score=2 → 0）', () {
      // 长度>=8: +1, 小写: +1 = score 2 → 非常弱(0)
      expect(EncryptionService.evaluatePasswordStrength('abcdefgh'), equals(0));
    });

    test('8位混合大小写为弱', () {
      // 长度>=8: +1, 小写: +1, 大写: +1 = score 3 → 弱(1)
      expect(EncryptionService.evaluatePasswordStrength('Abcdefgh'), equals(1));
    });

    test('12位混合大小写和数字为中等', () {
      expect(EncryptionService.evaluatePasswordStrength('Abcdef123456'), equals(2));
    });

    test('16位包含3种类型为强', () {
      expect(EncryptionService.evaluatePasswordStrength('Abcdefgh12345678'), equals(3));
    });

    test('16位包含所有类型为非常强', () {
      expect(EncryptionService.evaluatePasswordStrength('Abcdef12345678!@'), equals(4));
    });
  });

  group('getPasswordStrengthText', () {
    test('返回正确描述', () {
      expect(EncryptionService.getPasswordStrengthText(0), equals('非常弱'));
      expect(EncryptionService.getPasswordStrengthText(1), equals('弱'));
      expect(EncryptionService.getPasswordStrengthText(2), equals('中等'));
      expect(EncryptionService.getPasswordStrengthText(3), equals('强'));
      expect(EncryptionService.getPasswordStrengthText(4), equals('非常强'));
      expect(EncryptionService.getPasswordStrengthText(5), equals(''));
    });
  });

  group('getPasswordStrengthColor', () {
    test('返回正确颜色值', () {
      expect(EncryptionService.getPasswordStrengthColor(0), equals(0xFFE53935));
      expect(EncryptionService.getPasswordStrengthColor(1), equals(0xFFFF9800));
      expect(EncryptionService.getPasswordStrengthColor(2), equals(0xFFFFEB3B));
      expect(EncryptionService.getPasswordStrengthColor(3), equals(0xFF8BC34A));
      expect(EncryptionService.getPasswordStrengthColor(4), equals(0xFF4CAF50));
      expect(EncryptionService.getPasswordStrengthColor(5), equals(0xFF9E9E9E));
    });
  });
}
