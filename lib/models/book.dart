/// 一本书的数据模型：元数据 + 内容 + 阅读进度。
class Book {
  final String id;
  final String title;
  final String? author;
  final String content; // 全文
  final DateTime addedAt;

  int _position; // 当前阅读进度（字符偏移）
  double _fontSize;
  bool _darkMode;

  Book({
    required this.id,
    required this.title,
    this.author,
    required this.content,
    DateTime? addedAt,
    int position = 0,
    double fontSize = 18,
    bool darkMode = false,
  })  : _position = position,
        _fontSize = fontSize,
        _darkMode = darkMode,
        addedAt = addedAt ?? DateTime.now();

  int get position => _position;
  double get fontSize => _fontSize;
  bool get darkMode => _darkMode;

  set position(int v) => _position = v;
  set fontSize(double v) => _fontSize = v;
  set darkMode(bool v) => _darkMode = v;

  /// 读取进度百分比（0~1）
  double get progress =>
      content.isEmpty ? 0 : (_position / content.length).clamp(0.0, 1.0);

  /// 序列化为可存储的 JSON Map。
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'content': content,
        'addedAt': addedAt.toIso8601String(),
        'position': _position,
        'fontSize': _fontSize,
        'darkMode': _darkMode,
      };

  /// 从 JSON 恢复一本书。
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      content: json['content'] as String,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ??
          DateTime.now(),
      position: (json['position'] as num?)?.toInt() ?? 0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18,
      darkMode: json['darkMode'] as bool? ?? false,
    );
  }
}
