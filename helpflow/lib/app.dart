import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

/// 앱 루트 위젯
/// themeProvider를 구독하여 라이트/다크 테마를 동적으로 전환
/// ConsumerWidget으로 Riverpod ref에 접근
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 다크 모드 상태 구독 (변경 시 자동 리빌드)
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'HelpFlow',
      debugShowCheckedModeBanner: false,

      // 라이트 테마
      theme: AppTheme.light,

      // 다크 테마
      darkTheme: AppTheme.dark,

      // isDark 값에 따라 테마 모드 전환
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // go_router 라우터 설정 연결
      routerConfig: appRouter,
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app.dart
// 역할: MaterialApp.router 루트 위젯. themeProvider를 구독하여 라이트/다크 전환.
//       AppTheme.light / AppTheme.dark를 테마로 사용.
//       appRouter를 routerConfig에 연결.
