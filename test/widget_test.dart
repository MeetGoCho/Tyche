import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tyche/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TycheApp(),
      ),
    );

    // Home 화면이 표시되는지 확인
    expect(find.text('Tyche'), findsOneWidget);
  });
}
