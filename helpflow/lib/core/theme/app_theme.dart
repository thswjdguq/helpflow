import 'package:flutter/material.dart';
import '../design_system.dart';

/// 앱 전체 Material 3 테마 정의
/// design_system.dart의 색상 상수를 참조해 라이트/다크 테마를 명시적으로 구성한다.
/// 다크 모드는 Material 자동 생성 색상 대신 HelpFlowColors.dark* 상수를 직접 사용해
/// 영역별 색상 불일치 문제를 방지한다.
class AppTheme {
  AppTheme._(); // 인스턴스화 방지

  /// ColorScheme.fromSeed 기준 시드 컬러
  static const Color _seedColor = HelpFlowColors.primary;

  // ── 라이트 테마 ──────────────────────────────────────────────────────────

  /// 라이트 모드 ThemeData
  static ThemeData get light {
    // fromSeed 기반 생성 후 사이드바 색상(surfaceContainerLow)을 명시적으로 교체
    final base = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    final colorScheme = base.copyWith(
      surface: HelpFlowColors.background,           // 카드/탑바: 흰색
      onSurface: HelpFlowColors.textPrimary,        // 기본 텍스트: #191F28
      onSurfaceVariant: HelpFlowColors.gray700,     // 보조 텍스트: #4E5968
      outline: HelpFlowColors.border,               // 테두리: #E8EAED
      outlineVariant: HelpFlowColors.border,
      surfaceContainerLow: HelpFlowColors.surface,  // 사이드바: #F8F9FA
      surfaceContainer: HelpFlowColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // 스캐폴드 배경: 순백색
      scaffoldBackgroundColor: HelpFlowColors.background,

      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        backgroundColor: HelpFlowColors.background,
        foregroundColor: HelpFlowColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: HelpFlowColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: HelpFlowColors.border, width: 1),
        ),
      ),

      // ── 버튼 ──
      filledButtonTheme: FilledButtonThemeData(style: HelpFlowButtonStyles.filled),
      outlinedButtonTheme: OutlinedButtonThemeData(style: HelpFlowButtonStyles.outlined),
      textButtonTheme: TextButtonThemeData(style: HelpFlowButtonStyles.text),

      // ── NavigationRail (태블릿 미니 레일) ──
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: HelpFlowColors.surface,   // 사이드바: #F8F9FA
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: const IconThemeData(color: HelpFlowColors.gray500),
      ),

      // ── BottomNavigationBar (모바일 하단 바) ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HelpFlowColors.background,
        selectedItemColor: HelpFlowColors.primary,
        unselectedItemColor: HelpFlowColors.gray500,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Drawer (모바일 Drawer) ──
      drawerTheme: const DrawerThemeData(
        backgroundColor: HelpFlowColors.surface,
        elevation: 2,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: HelpFlowColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── TextTheme ──
      textTheme: const TextTheme(
        displayLarge: HelpFlowTextStyles.headline1,
        displayMedium: HelpFlowTextStyles.headline2,
        displaySmall: HelpFlowTextStyles.headline3,
        bodyLarge: HelpFlowTextStyles.body1,
        bodyMedium: HelpFlowTextStyles.body2,
        bodySmall: HelpFlowTextStyles.caption,
        labelLarge: HelpFlowTextStyles.button,
      ),
    );
  }

  // ── 다크 테마 ─────────────────────────────────────────────────────────────

  /// 다크 모드 ThemeData
  /// Material 자동생성 색상 대신 HelpFlowColors.dark* 상수를 명시적으로 지정해
  /// 사이드바/카드/배경의 색상 불일치를 방지한다.
  static ThemeData get dark {
    // fromSeed 기반 생성 후 핵심 색상을 명시적으로 교체
    final base = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    final colorScheme = base.copyWith(
      surface: HelpFlowColors.darkCard,            // 카드/팝업: #2C2C2C
      onSurface: HelpFlowColors.darkText,          // 기본 텍스트: #F0F0F0
      onSurfaceVariant: HelpFlowColors.darkSubtext, // 보조 텍스트: #A0A0A0
      outline: HelpFlowColors.darkBorder,          // 테두리: #3D3D3D
      outlineVariant: HelpFlowColors.darkBorder,
      surfaceContainerLow: HelpFlowColors.darkSurface,  // 사이드바: #1E1E1E
      surfaceContainer: HelpFlowColors.darkCard,
      surfaceContainerHigh: HelpFlowColors.darkCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // 스캐폴드 배경: 가장 어두운 #121212
      scaffoldBackgroundColor: HelpFlowColors.darkBackground,

      // ── AppBar ——
      // 사이드바(#1E1E1E)와 동일한 색상으로 일체감 유지
      appBarTheme: const AppBarTheme(
        backgroundColor: HelpFlowColors.darkSurface,
        foregroundColor: HelpFlowColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),

      // ── Card ——
      // 배경(#121212)보다 밝은 #2C2C2C로 카드 구분
      cardTheme: CardThemeData(
        elevation: 0,
        color: HelpFlowColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: HelpFlowColors.darkBorder, width: 1),
        ),
      ),

      // ── 버튼 ——
      filledButtonTheme: FilledButtonThemeData(style: HelpFlowButtonStyles.filled),
      outlinedButtonTheme: OutlinedButtonThemeData(style: HelpFlowButtonStyles.outlined),
      textButtonTheme: TextButtonThemeData(style: HelpFlowButtonStyles.text),

      // ── NavigationRail (태블릿 미니 레일) ——
      // 사이드바 배경: #1E1E1E
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: HelpFlowColors.darkSurface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: const IconThemeData(color: HelpFlowColors.darkSubtext),
      ),

      // ── BottomNavigationBar (모바일 하단 바) ——
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HelpFlowColors.darkSurface,
        selectedItemColor: HelpFlowColors.primary,
        unselectedItemColor: HelpFlowColors.darkSubtext,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Drawer ——
      drawerTheme: const DrawerThemeData(
        backgroundColor: HelpFlowColors.darkSurface,
        elevation: 2,
      ),

      // ── Chip ——
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      // ── Divider ——
      dividerTheme: const DividerThemeData(
        color: HelpFlowColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // ── TextTheme ——
      textTheme: const TextTheme(
        displayLarge: HelpFlowTextStyles.headline1,
        displayMedium: HelpFlowTextStyles.headline2,
        displaySmall: HelpFlowTextStyles.headline3,
        bodyLarge: HelpFlowTextStyles.body1,
        bodyMedium: HelpFlowTextStyles.body2,
        bodySmall: HelpFlowTextStyles.caption,
        labelLarge: HelpFlowTextStyles.button,
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_theme.dart
// 역할: Material 3 기반 라이트/다크 ThemeData 정의.
//       라이트: 흰 배경(#FFFFFF), 사이드바(#F8F9FA), 카드(#FFFFFF+#E8EAED 테두리).
//       다크: 배경(#121212), 사이드바(#1E1E1E), 카드(#2C2C2C+#3D3D3D 테두리).
//       ColorScheme.fromSeed().copyWith()로 surfaceContainerLow(사이드바),
//       surface(카드), outline(테두리)을 명시적 색상으로 교체해 영역별 색상 통일.
// 사용: AppTheme.light / AppTheme.dark를 MaterialApp.router themeMode에 전달.
