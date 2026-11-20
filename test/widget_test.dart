import 'package:flutter_test/flutter_test.dart';
import 'package:pure_reader/main.dart';

void main() {
  testWidgets('App 启动并显示书库页', (tester) async {
    await tester.pumpWidget(const PureReaderApp());
    await tester.pumpAndSettle();
    expect(find.text('净读'), findsOneWidget);
  });
}
