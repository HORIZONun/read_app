import 'package:flutter/material.dart';

import 'pages/library_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PureReaderApp());
}

class PureReaderApp extends StatelessWidget {
  const PureReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '净读',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const LibraryPage(),
    );
  }
}