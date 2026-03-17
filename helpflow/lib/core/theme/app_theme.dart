import 'package:flutter/material.dart';
import '../design_system.dart';

/// 앱 전체 Material 3 테마 정의
/// design_system.dart의 HelpFlowColors, HelpFlowButtonStyles 상수를 참조해 테마를 구성한다.
/// 라이트 테마와 다크 테마 모두 구현
class AppTheme {
  AppTheme._(); // 인스턴스화 방지

  // ── 시드 컬러 ─────────────────────────────────────
  /// ColorScheme.fromSeed 기준 시드 컬러 — design_system HelpFlowColors.primary 참조
  static const Color _seedColor = HelpFlowColors.primary;

  // ── 라이트 테마 ───────────────────────────────────
  /// 라이트 모드 ThemeData 반환
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      // 배경색을 design_system 기준 순백색으로 고정
      surface: HelpFlowColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // 스캐폴드 배경색: design_system 기준 순백색
      scaffoldBackgroundColor: HelpFlowColors.background,
      // ── AppBar 테마 ──
      appBarTheme: AppBarTheme(
        backgroundColor: HelpFlowColors.background,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      // ── Card 테마 ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: HelpFlowColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: HelpFlowColors.gray100,
            width: 1,
          ),
        ),
      ),
      // ── FilledButton 테마 — design_system radius 12, 넉넉한 패딩 적용 ──
      filledButtonTheme: FilledButtonThemeData(
        style: HelpFlowButtonStyles.filled,
      ),
      // ── OutlinedButton 테마 ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: HelpFlowButtonStyles.outlined,
      ),
      // ── TextButton 테마 ──
      textButtonTheme: TextButtonThemeData(
        style: HelpFlowButtonStyles.text,
      ),
      // ── NavigationRail 테마 ──
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: HelpFlowColors.surface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: const IconThemeData(color: HelpFlowColors.gray500),
      ),
      // ── BottomNavigationBar 테마 ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HelpFlowColors.background,
        selectedItemColor: HelpFlowColors.primary,
        unselectedItemColor: HelpFlowColors.gray500,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      // ── Drawer 테마 ──
      drawerTheme: const DrawerThemeData(
        backgroundColor: HelpFlowColors.background,
        elevation: 2,
      ),
      // ── Chip 테마 ──
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      // ── Divider 테마 ──
      dividerTheme: const DividerThemeData(
        color: HelpFlowColors.gray100,
        thickness: 1,
        space: 1,
      ),
      // ── TextTheme — design_system 텍스트 스타일 연결 ──
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

  // ── 다크 테마 ─────────────────────────────────────
  /// 다크 모드 ThemeData 반환
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // ── AppBar 테마 ──
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      // ── Card 테마 ──
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        color: colorScheme.surface,
      ),
      // ── FilledButton 테마 — design_system radius 12 적용 ──
      filledButtonTheme: FilledButtonThemeData(
        style: HelpFlowButtonStyles.filled,
      ),
      // ── OutlinedButton 테마 ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: HelpFlowButtonStyles.outlined,
      ),
      // ── TextButton 테마 ──
      textButtonTheme: TextButtonThemeData(
        style: HelpFlowButtonStyles.text,
      ),
      // ── NavigationRail 테마 ──
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      // ── BottomNavigationBar 테마 ──
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: HelpFlowColors.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      // ── Drawer 테마 ──
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 2,
      ),
      // ── Chip 테마 ──
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      // ── Divider 테마 ──
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // ── TextTheme — design_system 텍스트 스타일 연결 ──
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
//       design_system.dart의 HelpFlowColors, HelpFlowButtonStyles, HelpFlowTextStyles를
//       ColorScheme, scaffoldBackgroundColor, TextTheme, 버튼 테마에 연동.
//       라이트: 순백색 배경(#FFFFFF), 씨드 블루(#0057FF), radius 12 버튼.
//       다크: ColorScheme.fromSeed Brightness.dark 기반.
// 사용: AppTheme.light / AppTheme.dark를 MaterialApp.router에 전달.
