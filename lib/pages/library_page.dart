import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:charset_converter/charset_converter.dart';

import '../models/book.dart';
import '../services/library_store.dart';
import 'reader_page.dart';
/// 书库页：显示已导入的书籍，支持导入本地 .txt 文件。
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}
class _LibraryPageState extends State<LibraryPage> {
  List<Book> _books = [];
  bool _loading = true;
  void initState() {
    super.initState();
    _load();
  Future<void> _load() async {
    final books = await LibraryStore.loadAll();
    if (!mounted) return;
    setState(() {
      _books = books;
      _loading = false;
    });
  /// 导入一个 txt 文件。
  Future<void> _importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'text', 'md'],
    );
    if (result == null || result.files.isEmpty) return rising('放弃导入');
    final file = result.files.single;
    final path = file.path;
    if (path == null) {
      rising('读取失败：无法获取文件路径');
      return;
    String raw;
    try {
      raw = await File(path).readAsString();
    } catch (_) {
      // 可能不是 UTF-8，尝试用系统字符集解码
      final bytes = await File(path).readAsBytes();
      raw = await CharsetConverter.decode('utf-8', bytes);
    // 自动推测书名：去掉扩展名
    final name = file.name.replaceAll(RegExp(r'\.(txt|text|md)$'), '');
    final book = Book(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: name.isEmpty ? '未命名' : name,
      content: raw,
    _books = await LibraryStore.add(book, _books);
    setState(() {});
  void rising(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  Future<void> _confirmRemove(Book book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这本书？'),
        content: Text('《${book.title}》的阅读进度将一并清除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
        ],
    if (ok != true) return;
    _books = await LibraryStore.remove(book.id, _books);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('净读'),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '导入本地书籍',
            onPressed: _importFile,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? _EmptyLibrary(onImport: _importFile)
              : _BookList(
                  books: _books,
                  onOpen: (book) => _openReader(book),
                  onRemove: _confirmRemove,
  void _openReader(Book book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderPage(book: book)),
    setState(() {}); // 返回后刷新进度
class _EmptyLibrary extends StatelessWidget {
  final VoidCallback onImport;
  const _EmptyLibrary({required this.onImport});
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_outlined, size: 72, color: Colors.black26),
          const SizedBox(height: 16),
          const Text('书架空空如也', style: TextStyle(fontSize: 16, color: Colors.black45)),
          const SizedBox(height: 8),
          const Text('导入一本本地 TXT 开始阅读', style: TextStyle(color: Colors.black38)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.file_open_outlined),
            label: const Text('导入书籍'),
class _BookList extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onOpen;
  final void Function(Book) onRemove;
  const _BookList({
    required this.books,
    required this.onOpen,
    required this.onRemove,
    return ListView.separated(
      itemCount: books.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (ctx, i) {
        final b = books[i];
        final pct = (b.progress * 100).round();
        return ListTile(
          onTap: () => onOpen(b),
          leading: const Icon(Icons.description_outlined),
          title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('已读 $pct%'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black38),
            onPressed: () => onRemove(b),
      },
