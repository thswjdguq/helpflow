import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_text_styles.dart';

/// 사이드바 네비게이션 항목 데이터 모델
class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// 사이드바 위젯
/// 데스크탑 모드에서 항상 표시되는 전체 사이드바
/// 현재 경로 기반 활성 항목 강조, AnimatedContainer 전환 효과 포함
class SidebarWidget extends StatelessWidget {
  /// 현재 활성화된 경로 (GoRouter에서 전달)
  final String currentPath;

  /// 사이드바를 닫는 콜백 (Drawer 모드에서 사용)
  final VoidCallback? onClose;

  const SidebarWidget({
    super.key,
    required this.currentPath,
    this.onClose,
  });

  // ── 네비게이션 항목 목록 ─────────────────────────
  static const List<_NavItem> _navItems = [
    _NavItem(
      label: AppStrings.navDashboard,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.dashboard,
    ),
    _NavItem(
      label: AppStrings.navTickets,
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number,
      route: AppRoutes.tickets,
    ),
    _NavItem(
      label: AppStrings.navSettings,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      route: AppRoutes.settings,
    ),
  ];

  /// 현재 경로가 해당 navItem의 경로와 일치하는지 확인
  bool _isActive(String route) {
    if (route == AppRoutes.dashboard) {
      return currentPath == AppRoutes.dashboard || currentPath == '/';
    }
    return currentPath.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSizes.sidebarWidth,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 앱 로고 / 타이틀 영역 ──────────────────
          SizedBox(
            height: AppSizes.topBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: theme.colorScheme.primary,
                    size: AppSizes.iconLg,
                  ),
                  const SizedBox(width: AppSizes.paddingSm),
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  // Drawer 모드일 때 닫기 버튼 표시
                  if (onClose != null) ...[
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                      iconSize: AppSizes.iconMd,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: AppSizes.paddingSm),

          // ── 네비게이션 항목 목록 ───────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: AppSizes.paddingXs,
              ),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final active = _isActive(item.route);
                return _NavItemTile(
                  item: item,
                  isActive: active,
                  onTap: () {
                    onClose?.call(); // Drawer 모드면 먼저 닫기
                    context.go(item.route);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 개별 네비게이션 항목 타일 ─────────────────────────────────────────────────
/// AnimatedContainer로 활성 상태 전환 효과 적용
class _NavItemTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          leading: Icon(
            isActive ? item.activeIcon : item.icon,
            color: isActive
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
            size: AppSizes.iconMd,
          ),
          title: Text(
            item.label,
            style: AppTextStyles.navItem.copyWith(
              color: isActive
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: sidebar_widget.dart
// 역할: 대시보드/티켓관리/설정 네비게이션 사이드바.
//       현재 경로 기반 활성 항목 강조(secondaryContainer 배경).
//       AnimatedContainer로 활성 상태 전환 효과 적용.
//       onClose 콜백으로 Drawer 모드 지원.
