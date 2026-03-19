import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../views/layout/main_layout.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/tickets/ticket_list_screen.dart';
import '../../views/tickets/ticket_detail_screen.dart';
import '../../views/tickets/ticket_form_screen.dart';
import '../../views/settings/settings_screen.dart';

// ── 경로 상수 ───────────────────────────────────────────────────────────────

/// 앱 라우팅 경로 상수
/// 경로 문자열을 한 곳에서 관리해 오타 및 변경 시 실수 방지
class AppRoutes {
  AppRoutes._();

  // 인증 화면 (ShellRoute 밖 — 사이드바 없음)
  static const String login = '/login';
  static const String signup = '/signup';

  // 메인 화면 (ShellRoute 안 — 사이드바/하단바 공유)
  static const String dashboard = '/dashboard';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/tickets/:id';
  static const String ticketNew = '/tickets/new';
  static const String settings = '/settings';
}

// ── GoRouter 새로고침 리스너 ────────────────────────────────────────────────

/// Firebase Auth 스트림 변화를 GoRouter에 전달하는 ChangeNotifier
/// authStateChanges 스트림 이벤트 발생 시 notifyListeners() 호출 →
/// GoRouter가 redirect 콜백을 재실행해 인증 상태에 맞는 화면으로 이동
class _GoRouterRefreshStream extends ChangeNotifier {
  /// [stream] Firebase Auth authStateChanges 스트림
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    // 초기화 즉시 한 번 알림 (앱 시작 시 redirect 실행)
    notifyListeners();
    // 스트림 이벤트마다 GoRouter redirect 재실행 트리거
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ── GoRouter Provider ───────────────────────────────────────────────────────

/// GoRouter Riverpod 프로바이더
/// authStateProvider를 refreshListenable로 연결해 로그인 상태 변화 시
/// redirect 콜백이 자동으로 재실행되도록 설정
final appRouterProvider = Provider<GoRouter>((ref) {
  // Firebase Auth 스트림을 GoRouter 새로고침 리스너로 래핑
  // Firebase 미초기화 상태(플레이스홀더)에서는 빈 스트림으로 폴백
  ChangeNotifier refreshListenable;
  try {
    final authService = ref.read(authServiceProvider);
    refreshListenable = _GoRouterRefreshStream(authService.authStateChanges);
  } catch (_) {
    // Firebase 미초기화 시 단순 ChangeNotifier 사용 (갱신 없음)
    refreshListenable = ChangeNotifier();
  }

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refreshListenable,

    // ── 인증 상태 기반 리다이렉트 ────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      // 현재 접근 중인 경로
      final location = state.matchedLocation;

      // 인증 화면 여부 (/login, /signup)
      final isOnAuthPage =
          location == AppRoutes.login || location == AppRoutes.signup;

      // Firebase 로그인 여부 확인
      // Firebase 미초기화 예외 발생 시 미로그인으로 처리
      bool isLoggedIn = false;
      try {
        isLoggedIn = FirebaseAuth.instance.currentUser != null;
      } catch (_) {
        isLoggedIn = false;
      }

      // 미로그인 + 보호 경로 → 로그인 화면으로
      if (!isLoggedIn && !isOnAuthPage) return AppRoutes.login;

      // 로그인 완료 + 인증 화면 접근 → 대시보드로
      if (isLoggedIn && isOnAuthPage) return AppRoutes.dashboard;

      // 그 외: 리다이렉트 없음
      return null;
    },

    routes: [
      // ── 인증 화면 (사이드바 없음, ShellRoute 밖) ─────────────────────
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SignupScreen(),
        ),
      ),

      // ── 메인 화면 (ShellRoute: 사이드바/하단바 공유) ─────────────────
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.tickets,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TicketListScreen(),
            ),
          ),
          // /tickets/new는 /tickets/:id보다 먼저 등록해야 매칭 우선순위 확보
          GoRoute(
            path: AppRoutes.ticketNew,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TicketFormScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.ticketDetail,
            pageBuilder: (context, state) {
              final ticketId = state.pathParameters['id'] ?? '';
              return NoTransitionPage(
                child: TicketDetailScreen(ticketId: ticketId),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],

    // 존재하지 않는 경로 접근 시 대시보드로 (redirect가 /login으로 보냄)
    errorBuilder: (context, state) => const DashboardScreen(),
  );
});

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_router.dart
// 역할: go_router 기반 앱 라우터 Provider 정의.
//       AppRoutes: /login, /signup, /dashboard, /tickets, /tickets/new,
//                  /tickets/:id, /settings 경로 상수 관리.
//       _GoRouterRefreshStream: Firebase Auth 스트림 → ChangeNotifier 변환.
//       appRouterProvider: GoRouter Provider.
//         - refreshListenable로 인증 상태 변화 감지.
//         - redirect 콜백으로 미로그인 시 /login, 로그인 후 /dashboard 리다이렉트.
//         - /login, /signup은 ShellRoute 밖 (사이드바 없음).
// 사용: app.dart에서 ref.watch(appRouterProvider)로 MaterialApp.router에 전달.
