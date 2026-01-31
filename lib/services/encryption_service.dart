import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import '../utils/app_logger.dart';

/// 加密服务 - 用于加密存储的敏感数据
class EncryptionService {
  /// 旧版固定密钥（仅用于数据迁移）
  static const String _legacyKeyString = 'SecretVault2024!SecretVault2024!';
  static const String _legacyIvString = 'SecretVaultIV123';

  final Key _key;
  late final Encrypter _encrypter;

  EncryptionService(this._key) {
    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  /// 创建使用旧版固定密钥的实例（仅用于迁移）
  factory EncryptionService.legacy() {
    return EncryptionService(Key.fromUtf8(_legacyKeyString));
  }

  /// 生成随机 32 字节密钥
  static Key generateKey() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      bytes[i] = random.nextInt(256);
    }
    return Key(bytes);
  }

  /// 计算 HMAC-SHA256
  Uint8List _computeHmac(Uint8List data) {
    final hmac = crypto.Hmac(crypto.sha256, _key.bytes);
    return Uint8List.fromList(hmac.convert(data).bytes);
  }

  /// 加密文本
  /// 新格式: base64([IV 16字节] + [密文] + [HMAC 32字节])
  String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    try {
      final iv = IV.fromSecureRandom(16);
      final encrypted = _encrypter.encrypt(plainText, iv: iv);

      // IV + 密文
      final ivAndCipher = Uint8List(16 + encrypted.bytes.length);
      ivAndCipher.setRange(0, 16, iv.bytes);
      ivAndCipher.setRange(16, ivAndCipher.length, encrypted.bytes);

      // 计算 HMAC
      final hmac = _computeHmac(ivAndCipher);

      // 拼接 IV + 密文 + HMAC
      final combined = Uint8List(ivAndCipher.length + 32);
      combined.setRange(0, ivAndCipher.length, ivAndCipher);
      combined.setRange(ivAndCipher.length, combined.length, hmac);

      return base64.encode(combined);
    } catch (e) {
      AppLogger.error('加密错误', e);
      rethrow;
    }
  }

  /// 解密文本（支持新格式含 HMAC、不含 HMAC 和旧格式）
  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final bytes = base64.decode(encryptedText);

      // 尝试新格式含 HMAC: [IV 16] + [密文 N] + [HMAC 32]，最小 16+16+32=64
      if (bytes.length >= 64) {
        try {
          final ivAndCipher = Uint8List.fromList(
              bytes.sublist(0, bytes.length - 32));
          final storedHmac = Uint8List.fromList(
              bytes.sublist(bytes.length - 32));
          final computedHmac = _computeHmac(ivAndCipher);

          // 验证 HMAC
          bool hmacValid = true;
          for (int i = 0; i < 32; i++) {
            if (storedHmac[i] != computedHmac[i]) {
              hmacValid = false;
              break;
            }
          }

          if (hmacValid) {
            final iv = IV(Uint8List.fromList(ivAndCipher.sublist(0, 16)));
            final cipherBytes = Uint8List.fromList(ivAndCipher.sublist(16));
            final encrypted = Encrypted(cipherBytes);
            return _encrypter.decrypt(encrypted, iv: iv);
          }
          // HMAC 不匹配，尝试不含 HMAC 的格式
        } catch (_) {
          // 解密失败，继续尝试其他格式
        }
      }

      // 尝试不含 HMAC 的新格式: [IV 16] + [密文]
      if (bytes.length > 16) {
        try {
          final iv = IV(Uint8List.fromList(bytes.sublist(0, 16)));
          final cipherBytes = Uint8List.fromList(bytes.sublist(16));
          final encrypted = Encrypted(cipherBytes);
          return _encrypter.decrypt(encrypted, iv: iv);
        } catch (_) {
          // 继续尝试旧格式
        }
      }

      // 旧格式：使用固定 IV
      final legacyIv = IV.fromUtf8(_legacyIvString);
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: legacyIv);
    } catch (e) {
      AppLogger.error('解密错误', e);
      return encryptedText;
    }
  }

  /// 使用旧版固定 IV 解密（仅用于迁移）
  String decryptLegacy(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final iv = IV.fromUtf8(_legacyIvString);
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      AppLogger.error('旧格式解密错误', e);
      return encryptedText;
    }
  }

  /// 生成安全的随机密码
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    if (chars.isEmpty) chars = lowercase + numbers;

    final random = Random.secure();
    final password = List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();

    // 确保至少包含每种字符类型各一个
    List<String> result = password.split('');
    int index = 0;

    if (includeUppercase && !result.any((c) => uppercase.contains(c))) {
      result[index++] = uppercase[random.nextInt(uppercase.length)];
    }
    if (includeLowercase && !result.any((c) => lowercase.contains(c))) {
      result[index++] = lowercase[random.nextInt(lowercase.length)];
    }
    if (includeNumbers && !result.any((c) => numbers.contains(c))) {
      result[index++] = numbers[random.nextInt(numbers.length)];
    }
    if (includeSymbols && !result.any((c) => symbols.contains(c))) {
      result[index++] = symbols[random.nextInt(symbols.length)];
    }

    // 打乱顺序
    result.shuffle(random);
    return result.join();
  }

  /// 评估密码强度 (0-4)
  static int evaluatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // 长度评分
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // 字符类型评分
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]'))) score++;

    // 转换为0-4的评分
    if (score <= 2) return 0; // 非常弱
    if (score <= 4) return 1; // 弱
    if (score <= 5) return 2; // 中等
    if (score <= 6) return 3; // 强
    return 4; // 非常强
  }

  /// 获取密码强度描述
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
        return '非常弱';
      case 1:
        return '弱';
      case 2:
        return '中等';
      case 3:
        return '强';
      case 4:
        return '非常强';
      default:
        return '';
    }
  }

  /// 获取密码强度颜色
  static int getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return 0xFFE53935; // 红色
      case 1:
        return 0xFFFF9800; // 橙色
      case 2:
        return 0xFFFFEB3B; // 黄色
      case 3:
        return 0xFF8BC34A; // 浅绿
      case 4:
        return 0xFF4CAF50; // 绿色
      default:
        return 0xFF9E9E9E; // 灰色
    }
  }
}
