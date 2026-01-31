import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 语言设置管理
class LocaleProvider extends ChangeNotifier {
  static const _storageKey = 'app_locale';
  static const _storage = FlutterSecureStorage();

  Locale? _locale; // null = 跟随系统

  Locale? get locale => _locale;

  /// 从存储中加载语言设置
  Future<void> load() async {
    final code = await _storage.read(key: _storageKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  /// 设置语言，null 表示跟随系统
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    if (locale == null) {
      await _storage.delete(key: _storageKey);
    } else {
      await _storage.write(key: _storageKey, value: locale.languageCode);
    }
    notifyListeners();
  }
}
