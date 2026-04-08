import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
import 'sidebar_widget.dart';
import 'top_bar_widget.dart';

/// 메인 레이아웃 위젯
/// go_router ShellRoute의 builder에서 child를 받아 사이드바와 함께 배치
///
/// 반응형 3단계 분기:
///  - 데스크탑(≥1024px): SidebarWidget 항상 고정 표시
///  - 태블릿(≥600px): 아이콘만 보이는 NavigationRail(미니 레일)
///  - 모바일(<600px): Scaffold Drawer
class MainLayout extends StatelessWidget {
  /// ShellRoute가 제공하는 현재 활성 화면 위젯
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // ── 데스크탑 레이아웃 (≥1024px) ─────────────────
    if (width >= AppSizes.breakpointDesktop) {
      return _DesktopLayout(child: child);
    }

    // ── 태블릿 레이아웃 (≥600px) ─────────────────────
    if (width >= AppSizes.breakpointTablet) {
      return _TabletLayout(child: child);
    }

    // ── 모바일 레이아웃 (<600px) ─────────────────────
    return _MobileLayout(child: child);
  }
}

// ── 데스크탑 레이아웃 ─────────────────────────────────────────────────────────
/// 사이드바(240px) + 메인 영역(상단바 + 콘텐츠) 고정 배치
class _DesktopLayout extends StatelessWidget {
  final Widget child;

  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // 좌측 사이드바 고정
          SidebarWidget(currentPath: location),

          // 우측 메인 영역
          Expanded(
            child: Column(
              children: [
                // 상단 바
                const TopBarWidget(),
                // 실제 화면 콘텐츠
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 태블릿 레이아웃 ───────────────────────────────────────────────────────────
/// NavigationRail(아이콘만, 64px) + 메인 영역 배치
/// admin 역할이면 '사용자 관리' 레일 항목 추가
class _TabletLayout extends ConsumerWidget {
  final Widget child;

  const _TabletLayout({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);
    final isAdmin =
        ref.watch(currentUserProvider).value?.role == UserRole.admin;

    // admin 여부에 따라 목적지 목록 구성
    final routes = [
      AppRoutes.dashboard,
      AppRoutes.tickets,
      if (isAdmin) AppRoutes.users,
      AppRoutes.settings,
    ];

    int selectedIndex = routes.indexWhere(
      (r) => r != AppRoutes.dashboard
          ? location.startsWith(r)
          : location == AppRoutes.dashboard || location == '/',
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            labelType: NavigationRailLabelType.none,
            minWidth: AppSizes.railWidth,
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            onDestinationSelected: (index) =>
                context.go(routes[index]),
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text(AppStrings.navDashboard),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: Text(AppStrings.navTickets),
              ),
              if (isAdmin)
                const NavigationRailDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: Text(AppStrings.navUsers),
                ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text(AppStrings.navSettings),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                const TopBarWidget(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 모바일 레이아웃 ───────────────────────────────────────────────────────────
/// 하단 내비게이션 바 + 상단 바 + 콘텐츠 배치
/// admin 역할이면 '사용자 관리' 탭 추가
class _MobileLayout extends ConsumerWidget {
  final Widget child;

  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final isAdmin =
        ref.watch(currentUserProvider).value?.role == UserRole.admin;

    // 역할에 따라 탭 목적지 구성
    final routes = [
      AppRoutes.dashboard,
      AppRoutes.tickets,
      if (isAdmin) AppRoutes.users,
      AppRoutes.settings,
    ];

    int selectedIndex = routes.indexWhere(
      (r) => r != AppRoutes.dashboard
          ? location.startsWith(r)
          : location == AppRoutes.dashboard || location == '/',
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const TopBarWidget(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => context.go(routes[index]),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: AppStrings.navDashboard,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: AppStrings.navTickets,
          ),
          if (isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: AppStrings.navUsers,
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: main_layout.dart
// 역할: go_router ShellRoute용 반응형 메인 레이아웃.
//       데스크탑(≥1024px): 고정 사이드바(240px) + 상단바 + 콘텐츠.
//       태블릿(≥600px): NavigationRail(64px) + 상단바 + 콘텐츠.
//       모바일(<600px): 상단바 + 콘텐츠 + 하단 내비게이션 바(홈/티켓/리포트/설정).
