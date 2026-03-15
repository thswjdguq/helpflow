import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/theme_provider.dart';

/// 상단 바 위젯
/// 현재 페이지 제목 자동 표시, 새 티켓 버튼, 다크모드 토글 버튼 포함
/// ConsumerWidget으로 themeProvider를 구독
class TopBarWidget extends ConsumerWidget {
  /// 모바일 모드에서 Drawer를 열기 위한 GlobalKey
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const TopBarWidget({super.key, this.scaffoldKey});

  /// 현재 경로에 따른 페이지 제목 반환
  String _getTitle(String location) {
    if (location.startsWith(AppRoutes.tickets)) {
      if (location == AppRoutes.ticketNew) return AppStrings.ticketNewTitle;
      if (location == AppRoutes.tickets) return AppStrings.ticketListTitle;
      return AppStrings.ticketDetailTitle;
    }
    if (location.startsWith(AppRoutes.settings)) return AppStrings.settingsTitle;
    return AppStrings.dashboardTitle;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // 현재 경로 읽기
    final location = GoRouterState.of(context).matchedLocation;
    // 다크 모드 상태 구독
    final isDark = ref.watch(themeProvider);

    return Container(
      height: AppSizes.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          // ── 모바일 Drawer 열기 버튼 (좁은 화면에서만 표시) ──
          if (scaffoldKey != null)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => scaffoldKey!.currentState?.openDrawer(),
              tooltip: '메뉴 열기',
            ),

          // ── 현재 페이지 제목 ──────────────────────────
          Text(
            _getTitle(location),
            style: AppTextStyles.pageTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),

          const Spacer(),

          // ── 새 티켓 FilledButton ───────────────────────
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.ticketNew),
            icon: const Icon(Icons.add, size: AppSizes.iconSm),
            label: const Text(AppStrings.btnNewTicket),
          ),

          const SizedBox(width: AppSizes.paddingSm),

          // ── 다크 모드 토글 버튼 ───────────────────────
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
          ),
        ],
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: top_bar_widget.dart
// 역할: 상단 바 위젯. 현재 경로 기반 페이지 제목 자동 표시,
//       새 티켓 FilledButton(/tickets/new로 이동),
//       다크 모드 토글 버튼(themeProvider 구독).
//       모바일 모드에서 Drawer 열기 버튼 표시.
