import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
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
class _TabletLayout extends StatelessWidget {
  final Widget child;

  const _TabletLayout({required this.child});

  /// 현재 경로를 NavigationRail selectedIndex로 변환
  int _selectedIndex(String location) {
    if (location.startsWith(AppRoutes.tickets)) return 1;
    if (location.startsWith(AppRoutes.settings)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // 미니 레일 (아이콘만 표시, labelType: none)
          NavigationRail(
            selectedIndex: _selectedIndex(location),
            labelType: NavigationRailLabelType.none,
            minWidth: AppSizes.railWidth,
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.dashboard);
                case 1:
                  context.go(AppRoutes.tickets);
                case 2:
                  context.go(AppRoutes.settings);
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text(AppStrings.navDashboard),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: Text(AppStrings.navTickets),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text(AppStrings.navSettings),
              ),
            ],
          ),

          // 우측 메인 영역
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
/// Scaffold Drawer + 상단 바(햄버거 메뉴 버튼) 배치
class _MobileLayout extends StatelessWidget {
  final Widget child;

  const _MobileLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    // Drawer 열기/닫기를 위한 GlobalKey
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      key: scaffoldKey,
      // 좌측 Drawer에 SidebarWidget 배치
      drawer: SidebarWidget(
        currentPath: location,
        onClose: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // 상단 바 (햄버거 버튼 포함)
          TopBarWidget(scaffoldKey: scaffoldKey),
          // 실제 화면 콘텐츠
          Expanded(child: child),
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
//       모바일(<600px): Scaffold Drawer + 상단바(햄버거) + 콘텐츠.
