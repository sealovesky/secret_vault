import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// 备份服务 - 导出/导入加密备份
class BackupService {
  static const int _version = 2;
  static const String _magic = 'SVAULT';
  static const int _kdfIterations = 100000;
  static const int _saltLength = 32;

  /// 导出备份：数据库数据 → JSON → 密码加密 → .svault 文件
  /// 返回文件路径
  static Future<String> exportBackup(String password) async {
    final db = await DatabaseService.instance.database;

    // 读取所有原始加密数据（不解密）
    final passwords = await db.query('passwords');
    final notes = await db.query('notes');

    final data = {
      'version': _version,
      'exportedAt': DateTime.now().toIso8601String(),
      'passwords': passwords,
      'notes': notes,
    };

    final jsonStr = jsonEncode(data);

    // 生成随机盐值
    final salt = _generateRandomBytes(_saltLength);

    // 用密码派生密钥加密
    final keyBytes = _deriveKey(password, salt);
    final key = enc.Key(keyBytes);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonStr, iv: iv);

    // 文件格式 v2: [MAGIC 6字节] + [VERSION 1字节] + [SALT 32字节] + [IV 16字节] + [密文]
    final output = BytesBuilder();
    output.add(utf8.encode(_magic));
    output.addByte(_version);
    output.add(salt);
    output.add(iv.bytes);
    output.add(encrypted.bytes);

    // 保存到临时目录
    final tempDir = await getDatabasesPath();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = path.join(tempDir, 'backup_$timestamp.svault');
    final file = File(filePath);
    await file.writeAsBytes(output.toBytes());

    return filePath;
  }

  /// 导入备份：.svault 文件 → 密码解密 → 恢复到数据库
  /// 返回导入的数据统计
  static Future<Map<String, int>> importBackup(
    String filePath,
    String password, {
    bool merge = false,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    // 验证文件格式
    if (bytes.length < 7) {
      throw const FormatException('文件格式无效');
    }

    final magic = utf8.decode(bytes.sublist(0, 6));
    if (magic != _magic) {
      throw const FormatException('不是有效的备份文件');
    }

    final version = bytes[6];

    Uint8List salt;
    enc.IV iv;
    Uint8List cipherBytes;

    if (version == 1) {
      // v1 格式: [MAGIC 6] + [VERSION 1] + [IV 16] + [密文]
      if (bytes.length < 23) {
        throw const FormatException('文件格式无效');
      }
      salt = Uint8List.fromList(utf8.encode('SecretVault_Backup_Salt_v1'));
      iv = enc.IV(Uint8List.fromList(bytes.sublist(7, 23)));
      cipherBytes = Uint8List.fromList(bytes.sublist(23));
    } else if (version == 2) {
      // v2 格式: [MAGIC 6] + [VERSION 1] + [SALT 32] + [IV 16] + [密文]
      if (bytes.length < 55) {
        throw const FormatException('文件格式无效');
      }
      salt = Uint8List.fromList(bytes.sublist(7, 39));
      iv = enc.IV(Uint8List.fromList(bytes.sublist(39, 55)));
      cipherBytes = Uint8List.fromList(bytes.sublist(55));
    } else {
      throw FormatException('备份版本 $version 不被支持');
    }

    // 用密码解密
    final keyBytes = _deriveKey(password, salt, iterations: version == 1 ? 10000 : _kdfIterations);
    final key = enc.Key(keyBytes);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    String jsonStr;
    try {
      final encrypted = enc.Encrypted(cipherBytes);
      jsonStr = encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw const FormatException('密码错误或文件已损坏');
    }

    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final passwords = (data['passwords'] as List).cast<Map<String, dynamic>>();
    final notes = (data['notes'] as List).cast<Map<String, dynamic>>();

    final db = await DatabaseService.instance.database;

    int passwordCount = 0;
    int noteCount = 0;

    await db.transaction((txn) async {
      if (!merge) {
        // 覆盖模式：先清空
        await txn.delete('passwords');
        await txn.delete('notes');
      }

      for (final row in passwords) {
        final insertData = Map<String, dynamic>.from(row);
        insertData.remove('id'); // 移除原始 ID
        await txn.insert('passwords', insertData);
        passwordCount++;
      }

      for (final row in notes) {
        final insertData = Map<String, dynamic>.from(row);
        insertData.remove('id');
        await txn.insert('notes', insertData);
        noteCount++;
      }
    });

    return {
      'passwords': passwordCount,
      'notes': noteCount,
    };
  }

  /// 生成随机字节
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// 密码派生密钥（HMAC-SHA256 迭代）
  static Uint8List _deriveKey(String password, Uint8List salt, {int iterations = _kdfIterations}) {
    var key = utf8.encode(password);

    for (int i = 0; i < iterations; i++) {
      final hmac = Hmac(sha256, key);
      key = Uint8List.fromList(hmac.convert(salt).bytes);
    }

    return Uint8List.fromList(key);
  }
}
