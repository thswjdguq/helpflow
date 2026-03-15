import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../views/layout/main_layout.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/tickets/ticket_list_screen.dart';
import '../../views/tickets/ticket_detail_screen.dart';
import '../../views/tickets/ticket_form_screen.dart';
import '../../views/settings/settings_screen.dart';

/// 앱 라우팅 경로 상수
/// 경로 변경 시 이 클래스만 수정하면 됨
class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/dashboard';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/tickets/:id';
  static const String ticketNew = '/tickets/new';
  static const String settings = '/settings';
}

/// go_router 기반 앱 라우터
/// ShellRoute로 사이드바(MainLayout)를 모든 하위 경로에서 공유
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    // ── ShellRoute: 사이드바/상단바를 공유하는 레이아웃 쉘 ────────
    ShellRoute(
      // MainLayout이 child(실제 화면)를 받아 레이아웃 안에 배치
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainLayout(child: child);
      },
      routes: [
        // ── 대시보드 ──
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),

        // ── 티켓 목록 ──
        GoRoute(
          path: AppRoutes.tickets,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TicketListScreen(),
          ),
        ),

        // ── 새 티켓 생성 (/tickets/new를 :id보다 먼저 등록해야 매칭 우선순위 확보)
        GoRoute(
          path: AppRoutes.ticketNew,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TicketFormScreen(),
          ),
        ),

        // ── 티켓 상세 ──
        GoRoute(
          path: AppRoutes.ticketDetail,
          pageBuilder: (context, state) {
            // URL 경로 파라미터에서 티켓 ID 추출
            final ticketId = state.pathParameters['id'] ?? '';
            return NoTransitionPage(
              child: TicketDetailScreen(ticketId: ticketId),
            );
          },
        ),

        // ── 설정 ──
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],

  // ── 오류 처리: 존재하지 않는 경로 접근 시 대시보드로 리다이렉트 ──
  errorBuilder: (context, state) => const DashboardScreen(),
);

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_router.dart
// 역할: go_router ShellRoute 기반 라우터 정의.
//       /dashboard, /tickets, /tickets/new, /tickets/:id, /settings 경로 관리.
//       MainLayout을 ShellRoute builder로 사용해 사이드바를 모든 화면에서 공유.
//       NoTransitionPage로 화면 전환 시 불필요한 애니메이션 제거.
// 사용: MaterialApp.router(routerConfig: appRouter)에 전달.
