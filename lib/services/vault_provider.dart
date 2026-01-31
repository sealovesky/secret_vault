import 'package:flutter/foundation.dart';
import '../models/password_item.dart';
import '../models/note_item.dart';
import 'database_service.dart';

/// 数据状态管理
class VaultProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;

  List<PasswordItem> _passwords = [];
  List<NoteItem> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  // 分页状态
  static const int _pageSize = 20;
  bool _hasMorePasswords = true;
  bool _hasMoreNotes = true;
  bool _isLoadingMore = false;

  // Getters
  List<PasswordItem> get passwords => _filteredPasswords;
  List<NoteItem> get notes => _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get hasMorePasswords => _hasMorePasswords;
  bool get hasMoreNotes => _hasMoreNotes;
  bool get isLoadingMore => _isLoadingMore;

  /// 获取过滤后的密码列表
  List<PasswordItem> get _filteredPasswords {
    var result = _passwords;

    // 按分类过滤
    if (_selectedCategory != null) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    // 按搜索词过滤
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.username.toLowerCase().contains(query) ||
              (p.website?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return result;
  }

  /// 获取过滤后的笔记列表
  List<NoteItem> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;

    final query = _searchQuery.toLowerCase();
    return _notes
        .where((n) =>
            n.title.toLowerCase().contains(query) ||
            n.content.toLowerCase().contains(query))
        .toList();
  }

  /// 获取收藏的密码
  List<PasswordItem> get favoritePasswords =>
      _passwords.where((p) => p.isFavorite).toList();

  /// 获取置顶的笔记
  List<NoteItem> get pinnedNotes => _notes.where((n) => n.isPinned).toList();

  /// 按分类分组的密码
  Map<String, List<PasswordItem>> get passwordsByCategory {
    final map = <String, List<PasswordItem>>{};
    for (var item in _passwords) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  // ============ 加载数据 ============

  /// 加载所有数据
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        loadPasswords(),
        loadNotes(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载密码
  Future<void> loadPasswords() async {
    _passwords = await _db.getAllPasswords();
    _hasMorePasswords = _passwords.length >= _pageSize;
    notifyListeners();
  }

  /// 加载笔记
  Future<void> loadNotes() async {
    _notes = await _db.getAllNotes();
    _hasMoreNotes = _notes.length >= _pageSize;
    notifyListeners();
  }

  /// 加载更多密码（分页）
  Future<void> loadMorePasswords() async {
    if (_isLoadingMore || !_hasMorePasswords) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final more = await _db.getPasswordsPage(_passwords.length, _pageSize);
      if (more.isEmpty) {
        _hasMorePasswords = false;
      } else {
        _passwords.addAll(more);
        _hasMorePasswords = more.length >= _pageSize;
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// 加载更多笔记（分页）
  Future<void> loadMoreNotes() async {
    if (_isLoadingMore || !_hasMoreNotes) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final more = await _db.getNotesPage(_notes.length, _pageSize);
      if (more.isEmpty) {
        _hasMoreNotes = false;
      } else {
        _notes.addAll(more);
        _hasMoreNotes = more.length >= _pageSize;
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ============ 搜索和过滤 ============

  /// 设置搜索词
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// 设置分类过滤
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// 清除过滤
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // ============ 密码操作 ============

  /// 添加密码
  Future<void> addPassword(PasswordItem item) async {
    await _db.insertPassword(item);
    await loadPasswords();
  }

  /// 更新密码
  Future<void> updatePassword(PasswordItem item) async {
    await _db.updatePassword(item);
    await loadPasswords();
  }

  /// 删除密码
  Future<void> deletePassword(int id) async {
    await _db.deletePassword(id);
    await loadPasswords();
  }

  /// 切换收藏
  Future<void> togglePasswordFavorite(PasswordItem item) async {
    await _db.togglePasswordFavorite(item.id!, !item.isFavorite);
    await loadPasswords();
  }

  // ============ 笔记操作 ============

  /// 添加笔记
  Future<void> addNote(NoteItem item) async {
    await _db.insertNote(item);
    await loadNotes();
  }

  /// 更新笔记
  Future<void> updateNote(NoteItem item) async {
    await _db.updateNote(item);
    await loadNotes();
  }

  /// 删除笔记
  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
    await loadNotes();
  }

  /// 切换置顶
  Future<void> toggleNotePinned(NoteItem item) async {
    await _db.toggleNotePinned(item.id!, !item.isPinned);
    await loadNotes();
  }

  // ============ 统计 ============

  /// 获取统计信息
  Future<Map<String, int>> getStats() async {
    final passwordCount = await _db.getPasswordCount();
    final noteCount = await _db.getNoteCount();
    return {
      'passwords': passwordCount,
      'notes': noteCount,
      'favorites': favoritePasswords.length,
    };
  }
}
