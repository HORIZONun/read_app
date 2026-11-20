import 'package:flutter/material.dart';

import '../models/book.dart';

/// 阅读页：横向翻页、可调字号、记录进度、切换日/夜。
class ReaderPage extends StatefulWidget {
  final Book book;
  const ReaderPage({super.key, required this.book});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late Book _book;
  late int _currentPage;
  late PageController _controller;

  /// 分页结果：每一页的 (起始偏移, 结束偏移)，开区间 [start, end)。
  List<TextRange> _pages = [];

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _currentPage = 0;
    _controller = PageController();
    // 分页在 build 布局确定后再做（见 _onLayoutDone）
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(),
      appBar: AppBar(
        backgroundColor: _bg(),
        title: Text(_book.title),
        actions: [
          IconButton(
            icon: Icon(
              _book.darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: '切换日/夜',
            onPressed: _toggleTheme,
          ),
          PopupMenuButton<String>(
            onSelected: _onMenu,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'A-', child: Text('缩小字号')),
              const PopupMenuItem(value: 'A+', child: Text('放大字号')),
              const PopupMenuItem(value: 'jump', child: Text('跳转到进度…')),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          _ensurePages(constraints);
          return Column(
            children: [
              Expanded(
                child: _pages.isEmpty
                    ? const Center(child: Text('（空书）'))
                    : PageView.builder(
                        controller: _controller,
                        itemCount: _pages.length,
                        onPageChanged: (i) {
                          setState(() {
                            _currentPage = i;
                            _book.position = _pages[i].start;
                          });
                          _save();
                        },
                        itemBuilder: (ctx, i) {
                          final r = _pages[i];
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Text(
                              _book.content.substring(r.start, r.end),
                              style: _textStyle(),
                            ),
                          );
                        },
                      ),
              ),
              _bottomBar(constraints),
            ],
          );
        },
      ),
    );
  }

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: _book.fontSize,
      height: 1.9,
      color: _ink(),
    );
  }

  Color _bg() =>
      _book.darkMode ? const Color(0xFF202020) : const Color(0xFFF7F4ED);
  Color _ink() => _book.darkMode ? const Color(0xFFC8C8C8) : const Color(0xFF333333);
  Color _muted() =>
      _book.darkMode ? const Color(0xFF9A9A9A) : const Color(0xFF8A8578);

  void _toggleTheme() {
    setState(() => _book.darkMode = !_book.darkMode);
    _save();
  }

  void _save() {
    // 书库由 LibraryPage 负责整体保存；这里记录进度由外层返回时统一写。
    widget.book.position = _book.position;
    widget.book.darkMode = _book.darkMode;
    widget.book.fontSize = _book.fontSize;
  }

  void _onMenu(String v) async {
    switch (v) {
      case 'A-':
        setState(() {
          _book.fontSize = (_book.fontSize - 2).clamp(12, 30).toDouble();
        });
        _save();
      case 'A+':
        setState(() {
          _book.fontSize = (_book.fontSize + 2).clamp(12, 30).toDouble();
        });
        _save();
      case 'jump':
        _jumpDialog();
    }
  }

  Future<void> _jumpDialog() async {
    final pct = _book.progress * 100;
    final controller = TextEditingController(text: pct.round().toString());
    final val = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('跳转到进度'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: '%',
            labelText: '输入 0~100',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, double.tryParse(controller.text)),
            child: const Text('跳转'),
          ),
        ],
      ),
    );
    if (val == null || !mounted) return;
    final target =
        ((val.clamp(0, 100) / 100) * _book.content.length).round();
    // 重新按目标偏移定位页
    setState(() {
      _book.position = target;
      _currentPage = _pageIndexFor(_book.position);
      if (_controller.hasClients) {
        _controller.jumpToPage(_currentPage);
      }
    });
    _save();
  }

  /// 找到包含给定字符偏移的页序号。
  int _pageIndexFor(int pos) {
    for (int i = 0; i < _pages.length; i++) {
      final r = _pages[i];
      if (pos >= r.start && pos < r.end) return i;
    }
    return _pages.isEmpty ? 0 : _pages.length - 1;
  }

  /// 根据当前尺寸与字号重新计算分页，并定位到 _book.position。
  void _ensurePages(BoxConstraints constraints) {
    final maxW = constraints.maxWidth - 48; // 左右 padding
    final maxH = constraints.maxHeight - 32; // 上下 padding
    if (maxW <= 0 || maxH <= 0) return;

    final newPages = _paginate(
      _book.content,
      _textStyle(),
      maxW,
      maxH,
    );
    if (newPages.length != _pages.length) {
      _pages = newPages;
      final idx = _pageIndexFor(_book.position);
      _currentPage = idx;
      // 在首帧后跳转，避免布局期间操作 controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients && _controller.page != idx.toDouble()) {
          _controller.jumpToPage(idx);
        }
      });
    }
  }

  /// 简单的按字符数分页：每页固定约可容纳的字符数（保守估算）。
  /// 说明：为保持可读与稳定，采用近似分页，翻页时按字符偏移切分，
  /// 对阅读场景足够精确。真正的按行测量用 TextPainter 可在后续迭代加入。
  List<TextRange> _paginate(
    String text,
    TextStyle style,
    double width,
    double height,
  ) {
    if (text.isEmpty) return [];
    // 估算：中文字符宽度约等于 fontSize；行高 = fontSize * heightFactor
    final lineHeight = style.fontSize! * (style.height ?? 1.0);
    final linesPerPage = (height / lineHeight).floor().clamp(1, 10000);
    final charsPerLine = (width / style.fontSize!).floor().clamp(1, 10000);
    final charsPerPage = linesPerPage * charsPerLine;

    final result = <TextRange>[];
    int start = 0;
    while (start < text.length) {
      int end = (start + charsPerPage).clamp(0, text.length);
      result.add(TextRange(start: start, end: end));
      start = end;
    }
    return result;
  }

  Widget _bottomBar(BoxConstraints constraints) {
    final total = _pages.isEmpty ? 0 : _pages.length;
    final pct = _book.progress * 100;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
      child: Row(
        children: [
          Text('$pct%', style: TextStyle(fontSize: 12, color: _muted())),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _book.progress,
                minHeight: 4,
                backgroundColor: _muted().withOpacity(0.15),
                color: _muted(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${_currentPage + 1} / $total',
            style: TextStyle(fontSize: 12, color: _muted()),
          ),
        ],
      ),
    );
  }
}
