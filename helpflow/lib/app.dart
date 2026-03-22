import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

/// 앱 루트 위젯
/// themeProvider로 라이트/다크 테마 전환,
/// appRouterProvider로 인증 상태 기반 라우팅 처리
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 다크 모드 상태 구독 (변경 시 자동 리빌드)
    final isDark = ref.watch(themeProvider);

    // appRouterProvider 구독
    // Firebase Auth 스트림 변화 시 redirect 콜백 자동 재실행
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'HelpFlow',
      debugShowCheckedModeBanner: false,

      // 라이트 테마
      theme: AppTheme.light,

      // 다크 테마
      darkTheme: AppTheme.dark,

      // isDark 값에 따라 테마 모드 전환
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // appRouterProvider에서 생성된 GoRouter 연결
      // 인증 상태 변화 시 자동으로 redirect 콜백 재실행
      routerConfig: router,
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app.dart
// 역할: MaterialApp.router 루트 위젯.
//       themeProvider 구독 → 라이트/다크 테마 전환.
//       appRouterProvider 구독 → GoRouter 인스턴스 수신.
//       Firebase Auth 상태 변화 시 GoRouter의 redirect 콜백이 자동 재실행되어
//       로그인/로그아웃 시 LoginScreen ↔ DashboardScreen 분기 처리.
