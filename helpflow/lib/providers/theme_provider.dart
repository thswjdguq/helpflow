import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 다크 모드 상태를 관리하는 Notifier
/// bool 값으로 다크 모드 여부를 관리 (true = 다크, false = 라이트)
class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    // 초기값: 라이트 모드
    return false;
  }

  /// 다크/라이트 모드 토글
  void toggle() {
    state = !state;
  }

  /// 명시적으로 다크 모드 설정
  void setDark() {
    state = true;
  }

  /// 명시적으로 라이트 모드 설정
  void setLight() {
    state = false;
  }
}

/// 전역 테마 프로바이더
/// isDark 상태를 읽으려면: ref.watch(themeProvider)
/// 토글하려면: ref.read(themeProvider.notifier).toggle()
final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  ThemeNotifier.new,
);

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: theme_provider.dart
// 역할: Riverpod NotifierProvider로 다크 모드 bool 상태 관리.
//       toggle(), setDark(), setLight() 메서드 제공.
//       app.dart에서 구독하여 MaterialApp.router 테마 전환에 사용.
// 사용: ref.watch(themeProvider) → bool (isDark)
//       ref.read(themeProvider.notifier).toggle()
