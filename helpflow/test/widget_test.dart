import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpflow/app.dart';

void main() {
  testWidgets('앱 실행 스모크 테스트', (WidgetTester tester) async {
    // ProviderScope로 감싸서 앱 실행
    await tester.pumpWidget(
      const ProviderScope(child: App()),
    );
    // 앱이 오류 없이 렌더링되는지 확인
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
