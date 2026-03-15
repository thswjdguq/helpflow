import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 앱 전체 Material 3 테마 정의
/// 라이트 테마와 다크 테마 모두 구현
class AppTheme {
  AppTheme._(); // 인스턴스화 방지

  // ── 시드 컬러 ─────────────────────────────────────
  /// ColorScheme.fromSeed 기준 시드 컬러 (브랜드 파란색)
  static const Color _seedColor = AppColors.primary;

  // ── 라이트 테마 ───────────────────────────────────
  /// 라이트 모드 ThemeData 반환
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
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
      // ── NavigationRail 테마 ──
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      // ── Drawer 테마 ──
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 2,
      ),
      // ── FilledButton 테마 ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
      // ── NavigationRail 테마 ──
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      // ── Drawer 테마 ──
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 2,
      ),
      // ── FilledButton 테마 ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_theme.dart
// 역할: Material 3 기반 라이트/다크 ThemeData 정의.
//       시드 컬러 0xFF0057FF 기준 ColorScheme.fromSeed 사용.
//       AppBar, Card, NavigationRail, Drawer, FilledButton, Chip, Divider 테마 포함.
// 사용: AppTheme.light / AppTheme.dark를 MaterialApp.router에 전달.
