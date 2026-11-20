# 净读 · 干净的本地阅读器

一个专注阅读的极简本地电子书阅读 App。导入本机 TXT 文件，即刻开始阅读。

## 功能

- 📥 导入本地 `.txt` / `.md` 文件
- 📖 横向翻页阅读
- 🔤 字号调节（A− / A+）
- 🎚 进度跳转（0~100%）
- 🌙 日/夜双主题
- 💾 书库与阅读进度本地持久化

## 技术栈

- Flutter / Dart
- `file_picker` 本地文件导入
- `shared_preferences` 本地持久化
- `charset_converter` 非 UTF-8（GBK 等）文本解码

## 构建

### 本地构建（需要 Flutter SDK 3.19+）

```bash
# 1. 首次：补齐 android / ios / web 平台文件（会保留已有 lib/ 与 pubspec.yaml）
flutter create .

# 2. 安装依赖
flutter pub get

# 3. 静态检查
flutter analyze

# 4. 运行（连接设备或模拟器）
flutter run

# 5. 打包 Android APK
flutter build apk --release
# 产物：build/app/outputs/flutter-apk/app-release.apk
```

### CI 自动构建（无需本地环境）

工程内置 GitHub Actions 工作流 `.github/workflows/build.yml`。
推到 GitHub 即可自动构建出 APK 并作为构建产物下载。

## 目录结构

```
lib/
  main.dart              入口
  theme/app_theme.dart   主题
  models/book.dart       书数据模型
  services/library_store.dart  本地存储
  pages/library_page.dart     书库页
  pages/reader_page.dart     阅读页
```
