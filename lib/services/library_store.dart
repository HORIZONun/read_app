import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

/// 本地书库存储：用 SharedPreferences 持久化书的列表与阅读进度。
class LibraryStore {
  static const String _key = 'library_books';

  /// 保存整个书库列表。
  static Future<void> saveAll(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final data = books.map((b) => b.toJson()).toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  /// 读取书库列表；无数据时返回空列表。
  static Future<List<Book>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 追加一本书并保存，返回新列表。
  static Future<List<Book>> add(Book book, List<Book> current) async {
    final next = [...current, book];
    await saveAll(next);
    return next;
  }

  /// 移除一本书并保存，返回新列表。
  static Future<List<Book>> remove(String id, List<Book> current) async {
    final next = current.where((b) => b.id != id).toList();
    await saveAll(next);
    return next;
  }
}
