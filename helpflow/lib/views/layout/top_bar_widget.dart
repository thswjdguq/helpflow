import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
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
    final location = GoRouterState.of(context).matchedLocation;
    final isDark = ref.watch(themeProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final role = currentUser?.role ?? UserRole.user;

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
          // ── 모바일 Drawer 열기 버튼 (좁은 화면에서만) ──
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

          // ── 새 티켓 버튼 (user 역할만 표시) ──────────
          if (role == UserRole.user) ...[
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.ticketNew),
              icon: const Icon(Icons.add, size: AppSizes.iconSm),
              label: const Text(AppStrings.btnNewTicket),
            ),
            const SizedBox(width: AppSizes.paddingSm),
          ],

          // ── 다크 모드 토글 버튼 ───────────────────────
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
          ),

          // ── 사용자 아바타 + 이름 ──────────────────────
          if (currentUser != null) ...[
            const SizedBox(width: AppSizes.paddingXs),
            _UserAvatar(user: currentUser),
          ],
        ],
      ),
    );
  }
}

// ── 사용자 아바타 위젯 ────────────────────────────────────────────────────────

/// 상단 바 우측에 표시되는 로그인 사용자 아바타 + 이름
class _UserAvatar extends StatelessWidget {
  final UserModel user;
  const _UserAvatar({required this.user});

  Color _roleColor(String role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFB71C1C);
      case UserRole.agent:
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF43A047);
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case UserRole.admin:
        return '관리자';
      case UserRole.agent:
        return '담당자';
      default:
        return '직원';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(user.role);
    final width = MediaQuery.sizeOf(context).width;
    final showName = width >= AppSizes.breakpointTablet;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 역할 색상 아바타
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        // 태블릿 이상에서만 이름 + 역할 표시
        if (showName) ...[
          const SizedBox(width: AppSizes.paddingXs),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name.isNotEmpty ? user.name : user.email,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                _roleLabel(user.role),
                style: AppTextStyles.bodySm.copyWith(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: top_bar_widget.dart
// 역할: 상단 바 위젯. 현재 경로 기반 페이지 제목 자동 표시,
//       새 티켓 FilledButton(/tickets/new로 이동),
//       다크 모드 토글 버튼(themeProvider 구독).
//       모바일 모드에서 Drawer 열기 버튼 표시.
