import 'dart:convert';
import 'dart:ui';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_item.dart';
import '../models/note_item.dart';
import '../utils/app_logger.dart';
import 'encryption_service.dart';

/// 数据库服务 - 单例模式
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  late EncryptionService _encryption;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyStorageKey = 'vault_encryption_key';
  static const String _migrationFlag = 'data_migrated_v2';
  static const String _demoDataFlag = 'demo_data_inserted';

  DatabaseService._init();

  /// 初始化加密服务（必须在使用数据库前调用）
  Future<void> initEncryption() async {
    final key = await _getOrCreateKey();
    _encryption = EncryptionService(key);

    // 确保数据库已初始化
    await database;

    // 检查是否需要迁移数据
    await _migrateDataIfNeeded();

    // 首次安装插入演示数据
    await _insertDemoDataIfNeeded();
  }

  /// 获取或创建加密密钥
  Future<Key> _getOrCreateKey() async {
    final existingKey = await _secureStorage.read(key: _keyStorageKey);
    if (existingKey != null) {
      return Key(base64.decode(existingKey));
    }

    // 首次启动，生成新密钥
    final newKey = EncryptionService.generateKey();
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64.encode(newKey.bytes),
    );
    return newKey;
  }

  /// 数据迁移：旧密钥 → 新密钥
  Future<void> _migrateDataIfNeeded() async {
    final migrated = await _secureStorage.read(key: _migrationFlag);
    if (migrated == 'true') return;

    final db = await database;
    final legacyEncryption = EncryptionService.legacy();

    // 检查是否有旧数据需要迁移
    final passwords = await db.query('passwords');
    final notes = await db.query('notes');

    if (passwords.isEmpty && notes.isEmpty) {
      // 没有数据，直接标记已迁移
      await _secureStorage.write(key: _migrationFlag, value: 'true');
      return;
    }

    // 在事务中完成迁移
    await db.transaction((txn) async {
      // 迁移密码
      for (final row in passwords) {
        final id = row['id'] as int;
        final encryptedPassword = row['password'] as String;
        final encryptedNotes = row['notes'] as String?;

        try {
          // 用旧密钥解密
          final plainPassword = legacyEncryption.decryptLegacy(encryptedPassword);
          final plainNotes = encryptedNotes != null && encryptedNotes.isNotEmpty
              ? legacyEncryption.decryptLegacy(encryptedNotes)
              : encryptedNotes;

          // 用新密钥加密
          final newEncryptedPassword = _encryption.encrypt(plainPassword);
          final newEncryptedNotes = plainNotes != null && plainNotes.isNotEmpty
              ? _encryption.encrypt(plainNotes)
              : plainNotes;

          await txn.update(
            'passwords',
            {
              'password': newEncryptedPassword,
              'notes': newEncryptedNotes,
            },
            where: 'id = ?',
            whereArgs: [id],
          );
        } catch (e) {
          AppLogger.error('迁移密码 $id 失败', e);
        }
      }

      // 迁移笔记
      for (final row in notes) {
        final id = row['id'] as int;
        final encryptedContent = row['content'] as String;

        try {
          final plainContent = legacyEncryption.decryptLegacy(encryptedContent);
          final newEncryptedContent = _encryption.encrypt(plainContent);

          await txn.update(
            'notes',
            {'content': newEncryptedContent},
            where: 'id = ?',
            whereArgs: [id],
          );
        } catch (e) {
          AppLogger.error('迁移笔记 $id 失败', e);
        }
      }
    });

    // 标记迁移完成
    await _secureStorage.write(key: _migrationFlag, value: 'true');
  }

  /// 首次安装时插入演示数据
  Future<void> _insertDemoDataIfNeeded() async {
    final inserted = await _secureStorage.read(key: _demoDataFlag);
    if (inserted == 'true') return;

    final db = await database;
    final passwords = await db.query('passwords');
    final notes = await db.query('notes');

    // 已有数据则跳过（可能是从备份恢复的）
    if (passwords.isNotEmpty || notes.isNotEmpty) {
      await _secureStorage.write(key: _demoDataFlag, value: 'true');
      return;
    }

    final now = DateTime.now();
    final isZh = PlatformDispatcher.instance.locale.languageCode == 'zh';

    // 演示密码
    final demoPasswords = [
      PasswordItem(
        title: 'Gmail',
        username: 'demo@gmail.com',
        password: 'P@ssw0rd2024!',
        website: 'https://mail.google.com',
        notes: isZh
            ? '这是一条演示密码，你可以随时编辑或删除它。'
            : 'This is a demo password. Feel free to edit or delete it.',
        category: '邮箱',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      PasswordItem(
        title: isZh ? '淘宝' : 'Amazon',
        username: 'demo_shopper',
        password: 'Sh0pp1ng#Secure',
        website: isZh ? 'https://www.taobao.com' : 'https://www.amazon.com',
        category: '购物',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      PasswordItem(
        title: 'GitHub',
        username: 'dev_demo',
        password: 'G1tHub@2024!Dev',
        website: 'https://github.com',
        notes: isZh
            ? '开发账号，已开启双因素认证。'
            : 'Dev account, 2FA enabled.',
        category: '工作',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    // 演示笔记
    final demoNotes = [
      NoteItem(
        title: isZh ? '欢迎使用私密保险箱' : 'Welcome to Secret Vault',
        content: isZh
            ? '这是你的私密空间，所有数据都在本地加密存储。\n\n'
                '• 左侧「密码」标签可以管理你的账号密码\n'
                '• 右侧「笔记」标签可以记录私密信息\n'
                '• 点击右下角 + 按钮添加新内容\n'
                '• 左滑可以快速删除\n\n'
                '这条笔记是演示内容，你可以随时编辑或删除它。'
            : 'This is your private space. All data is encrypted locally.\n\n'
                '• Use the "Passwords" tab to manage your accounts\n'
                '• Use the "Notes" tab to store private information\n'
                '• Tap the + button to add new content\n'
                '• Swipe left to quickly delete\n\n'
                'This is a demo note. Feel free to edit or delete it.',
        color: 'blue',
        isPinned: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      NoteItem(
        title: isZh ? '购物清单' : 'Shopping List',
        content: isZh
            ? '□ 牛奶\n□ 面包\n□ 水果\n□ 洗衣液\n□ 纸巾'
            : '□ Milk\n□ Bread\n□ Fruits\n□ Detergent\n□ Tissues',
        color: 'yellow',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    await db.transaction((txn) async {
      for (final item in demoPasswords) {
        final encrypted = item.copyWith(
          password: _encryption.encrypt(item.password),
          notes: item.notes != null ? _encryption.encrypt(item.notes!) : null,
        );
        await txn.insert('passwords', encrypted.toMap());
      }
      for (final item in demoNotes) {
        final encrypted = item.copyWith(
          content: _encryption.encrypt(item.content),
        );
        await txn.insert('notes', encrypted.toMap());
      }
    });

    await _secureStorage.write(key: _demoDataFlag, value: 'true');
  }

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('secret_vault.db');
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// 创建数据库表
  Future _createDB(Database db, int version) async {
    // 密码表
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        website TEXT,
        notes TEXT,
        category TEXT DEFAULT '其他',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // 笔记表
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        color TEXT DEFAULT 'default',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_pinned INTEGER DEFAULT 0
      )
    ''');

    // 创建索引
    await db.execute(
        'CREATE INDEX idx_passwords_category ON passwords(category)');
    await db.execute(
        'CREATE INDEX idx_passwords_favorite ON passwords(is_favorite)');
    await db.execute('CREATE INDEX idx_notes_pinned ON notes(is_pinned)');
  }

  /// 数据库升级
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: 预留升级路径，当前无 schema 变更
    // 后续版本在此添加迁移逻辑，例如:
    // if (oldVersion < 3) {
    //   await db.execute('ALTER TABLE passwords ADD COLUMN totp TEXT');
    // }
  }

  // ============ 密码相关操作 ============

  /// 添加密码
  Future<int> insertPassword(PasswordItem item) async {
    final db = await database;
    final encryptedItem = item.copyWith(
      password: _encryption.encrypt(item.password),
      notes: item.notes != null ? _encryption.encrypt(item.notes!) : null,
    );
    return await db.insert('passwords', encryptedItem.toMap());
  }

  /// 获取所有密码
  Future<List<PasswordItem>> getAllPasswords() async {
    final db = await database;
    final maps = await db.query(
      'passwords',
      orderBy: 'is_favorite DESC, updated_at DESC',
    );

    return maps.map((map) {
      final item = PasswordItem.fromMap(map);
      return item.copyWith(
        password: _encryption.decrypt(item.password),
        notes: item.notes != null ? _encryption.decrypt(item.notes!) : null,
      );
    }).toList();
  }

  /// 按分类获取密码
  Future<List<PasswordItem>> getPasswordsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'passwords',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'is_favorite DESC, updated_at DESC',
    );

    return maps.map((map) {
      final item = PasswordItem.fromMap(map);
      return item.copyWith(
        password: _encryption.decrypt(item.password),
        notes: item.notes != null ? _encryption.decrypt(item.notes!) : null,
      );
    }).toList();
  }

  /// 搜索密码
  Future<List<PasswordItem>> searchPasswords(String query) async {
    final db = await database;
    final maps = await db.query(
      'passwords',
      where: 'title LIKE ? OR username LIKE ? OR website LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) {
      final item = PasswordItem.fromMap(map);
      return item.copyWith(
        password: _encryption.decrypt(item.password),
        notes: item.notes != null ? _encryption.decrypt(item.notes!) : null,
      );
    }).toList();
  }

  /// 更新密码
  Future<int> updatePassword(PasswordItem item) async {
    final db = await database;
    final encryptedItem = item.copyWith(
      password: _encryption.encrypt(item.password),
      notes: item.notes != null ? _encryption.encrypt(item.notes!) : null,
    );
    return await db.update(
      'passwords',
      encryptedItem.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 删除密码
  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 切换收藏状态
  Future<void> togglePasswordFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'passwords',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 分页获取密码
  Future<List<PasswordItem>> getPasswordsPage(int offset, int limit) async {
    final db = await database;
    final maps = await db.query(
      'passwords',
      orderBy: 'is_favorite DESC, updated_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) {
      final item = PasswordItem.fromMap(map);
      return item.copyWith(
        password: _encryption.decrypt(item.password),
        notes: item.notes != null ? _encryption.decrypt(item.notes!) : null,
      );
    }).toList();
  }

  // ============ 笔记相关操作 ============

  /// 添加笔记
  Future<int> insertNote(NoteItem item) async {
    final db = await database;
    final encryptedItem = item.copyWith(
      content: _encryption.encrypt(item.content),
    );
    return await db.insert('notes', encryptedItem.toMap());
  }

  /// 获取所有笔记
  Future<List<NoteItem>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      orderBy: 'is_pinned DESC, updated_at DESC',
    );

    return maps.map((map) {
      final item = NoteItem.fromMap(map);
      return item.copyWith(
        content: _encryption.decrypt(item.content),
      );
    }).toList();
  }

  /// 分页获取笔记
  Future<List<NoteItem>> getNotesPage(int offset, int limit) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      orderBy: 'is_pinned DESC, updated_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) {
      final item = NoteItem.fromMap(map);
      return item.copyWith(
        content: _encryption.decrypt(item.content),
      );
    }).toList();
  }

  /// 搜索笔记
  Future<List<NoteItem>> searchNotes(String query) async {
    final all = await getAllNotes();
    final lowerQuery = query.toLowerCase();
    return all
        .where((note) =>
            note.title.toLowerCase().contains(lowerQuery) ||
            note.content.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 更新笔记
  Future<int> updateNote(NoteItem item) async {
    final db = await database;
    final encryptedItem = item.copyWith(
      content: _encryption.encrypt(item.content),
    );
    return await db.update(
      'notes',
      encryptedItem.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 删除笔记
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 切换置顶状态
  Future<void> toggleNotePinned(int id, bool isPinned) async {
    final db = await database;
    await db.update(
      'notes',
      {'is_pinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ 统计 ============

  /// 获取密码数量
  Future<int> getPasswordCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM passwords');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取笔记数量
  Future<int> getNoteCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 关闭数据库
  Future close() async {
    final db = await database;
    db.close();
  }
}
