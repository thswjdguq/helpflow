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

// ── GoRouter 새로고침 알리미 ────────────────────────────────────────────────

/// GoRouter redirect 재실행을 트리거하는 ChangeNotifier
/// Riverpod ref.listen()을 통해 authStateProvider 변화를 감지하고
/// notifyListeners()를 호출해 GoRouter가 redirect를 다시 평가하게 한다.
class _GoRouterNotifier extends ChangeNotifier {
  /// 외부에서 GoRouter refresh를 트리거할 때 호출
  void notify() => notifyListeners();
}

// ── GoRouter Provider ───────────────────────────────────────────────────────

/// GoRouter Riverpod 프로바이더
///
/// 핵심 동작:
///  1. _GoRouterNotifier를 refreshListenable로 사용
///  2. ref.listen(authStateProvider)로 인증 상태 변화 감지 → notify() 호출
///  3. redirect 콜백에서 ref.read(authStateProvider)로 현재 인증 상태 확인
///  4. initialLocation = /login → 앱 시작 시 항상 로그인 화면부터 시작
///     (로그인 상태이면 redirect가 즉시 /dashboard로 보냄)
final appRouterProvider = Provider<GoRouter>((ref) {
  // GoRouter refresh 알리미 생성
  final notifier = _GoRouterNotifier();

  // authStateProvider(Firebase Auth 스트림) 변화를 감지해 GoRouter redirect 재실행
  // ref.listen은 authStateProvider가 새 값을 방출할 때마다 콜백 실행
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, _) {
    notifier.notify();
  });

  return GoRouter(
    // ── 앱 시작 위치: 항상 /login ─────────────────────────────────────────
    // redirect 콜백이 로그인 상태를 확인해 /dashboard로 자동 이동
    // 이 설정으로 비로그인 상태에서 /dashboard 직접 접근을 완전히 차단
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,

    // ── 인증 상태 기반 리다이렉트 ─────────────────────────────────────────
    // 매 라우팅 시도마다 실행 (새 페이지 이동, 앱 시작, 인증 상태 변화 시)
    redirect: (BuildContext context, GoRouterState state) {
      // 현재 접근 중인 경로
      final location = state.matchedLocation;

      // 인증 화면(/login, /signup) 여부
      final isOnAuthPage =
          location == AppRoutes.login || location == AppRoutes.signup;

      // Riverpod에서 현재 인증 상태를 동기적으로 읽기
      // authStateProvider는 Firebase Auth authStateChanges 스트림
      final authState = ref.read(authStateProvider);

      return authState.when(
        // ── 인증 상태 확인 완료 ──────────────────────────────────────────
        data: (user) {
          // 미로그인 + 인증 화면 아님 → 로그인 화면으로 강제 이동
          if (user == null && !isOnAuthPage) return AppRoutes.login;
          // 로그인 완료 + 인증 화면 접근 → 대시보드로 이동
          if (user != null && isOnAuthPage) return AppRoutes.dashboard;
          // 그 외: 현재 경로 유지
          return null;
        },
        // ── 인증 상태 로딩 중 ────────────────────────────────────────────
        // Firebase Auth 초기화 중: 인증 화면이 아니면 /login에서 대기
        loading: () => isOnAuthPage ? null : AppRoutes.login,
        // ── 인증 에러 (Firebase 미초기화 등) ────────────────────────────
        // 에러 시에도 보호 경로 접근 차단
        error: (_, _) => isOnAuthPage ? null : AppRoutes.login,
      );
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

    // 존재하지 않는 경로 → redirect가 인증 상태에 따라 처리
    errorBuilder: (context, state) => const LoginScreen(),
  );
});

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: app_router.dart
// 역할: go_router 기반 앱 라우터 Provider 정의.
//       AppRoutes: /login, /signup, /dashboard, /tickets, /tickets/new,
//                  /tickets/:id, /settings 경로 상수 관리.
//       _GoRouterNotifier: ref.listen(authStateProvider) 변화를 ChangeNotifier로 전달.
//       appRouterProvider:
//         - initialLocation: /login → 앱 시작 시 항상 로그인 화면 먼저.
//         - redirect: Riverpod authStateProvider 기반으로 인증 상태 확인.
//           · 미로그인 + 보호 경로 → /login 강제.
//           · 로그인 + 인증 화면 → /dashboard 자동 이동.
//           · 로딩/에러 → /login에서 대기 (보호 경로 차단).
//         - /login, /signup은 ShellRoute 밖 (사이드바 없음).
// 사용: app.dart에서 ref.watch(appRouterProvider)로 MaterialApp.router에 전달.
