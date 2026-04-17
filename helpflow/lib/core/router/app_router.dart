import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../views/layout/main_layout.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/tickets/ticket_list_screen.dart';
import '../../views/tickets/ticket_detail_screen.dart';
import '../../views/tickets/ticket_form_screen.dart';
import '../../views/admin/user_management_screen.dart';
import '../../views/reports/reports_screen.dart';
import '../../views/settings/settings_screen.dart';

// ── 경로 상수 ───────────────────────────────────────────────────────────────

/// 앱 라우팅 경로 상수
/// 경로 문자열을 한 곳에서 관리해 오타 및 변경 시 실수 방지
class AppRoutes {
  AppRoutes._();

  // 스플래시 (앱 시작 로딩)
  static const String splash = '/splash';

  // 인증 화면 (ShellRoute 밖 — 사이드바 없음)
  static const String login = '/login';
  static const String signup = '/signup';

  // 메인 화면 (ShellRoute 안 — 사이드바/하단바 공유)
  static const String dashboard = '/dashboard';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/tickets/:id';
  static const String ticketNew = '/tickets/new';
  static const String users = '/users';
  static const String reports = '/reports';
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
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, _) {
    notifier.notify();
  });

  // currentUserProvider 변화 시에도 redirect 재실행
  // 로그인 직후 Firestore에서 역할 정보를 로드한 뒤 올바른 초기 화면으로 이동하기 위함
  ref.listen<AsyncValue<UserModel?>>(currentUserProvider, (_, _) {
    notifier.notify();
  });

  return GoRouter(
    // ── 앱 시작 위치: 스플래시 ──────────────────────────────────────────
    // Firebase Auth 초기화 중 스플래시를 표시하고,
    // 완료되면 redirect가 인증 상태에 따라 알맞은 화면으로 자동 이동
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,

    // ── 인증 상태 기반 리다이렉트 ─────────────────────────────────────────
    // 매 라우팅 시도마다 실행 (새 페이지 이동, 앱 시작, 인증 상태 변화 시)
    redirect: (BuildContext context, GoRouterState state) {
      // 현재 접근 중인 경로
      final location = state.matchedLocation;

      // 각 화면 여부 판별
      final isOnSplash = location == AppRoutes.splash;
      final isOnAuthPage =
          location == AppRoutes.login || location == AppRoutes.signup;

      // Riverpod에서 현재 인증 상태를 동기적으로 읽기
      final authState = ref.read(authStateProvider);

      return authState.when(
        // ── 인증 상태 확인 완료 ──────────────────────────────────────────
        data: (user) {
          // 역할 기반 초기 화면 결정 헬퍼
          String roleBasedHome() {
            final currentUser = ref.read(currentUserProvider);
            return currentUser.when(
              data: (userData) =>
                  userData?.role == UserRole.admin
                      ? AppRoutes.dashboard
                      : AppRoutes.tickets,
              loading: () => AppRoutes.tickets,
              error: (_, _) => AppRoutes.tickets,
            );
          }

          // 스플래시 → 인증 완료 후 즉시 분기
          if (isOnSplash) {
            if (user == null) return AppRoutes.login;
            // Firestore 역할 로딩 중이면 잠시 스플래시에서 대기
            final currentUser = ref.read(currentUserProvider);
            return currentUser.when(
              data: (userData) =>
                  userData?.role == UserRole.admin
                      ? AppRoutes.dashboard
                      : AppRoutes.tickets,
              loading: () => null, // 역할 로딩 완료까지 스플래시 유지
              error: (_, _) => AppRoutes.tickets,
            );
          }

          // 미로그인 + 보호 경로 → 로그인 화면으로 강제 이동
          if (user == null && !isOnAuthPage) return AppRoutes.login;

          // 로그인 완료 + 인증 화면 → 역할에 따라 초기 화면 결정
          if (user != null && isOnAuthPage) return roleBasedHome();

          // 그 외: 현재 경로 유지
          return null;
        },
        // ── Firebase Auth 초기화 중 ──────────────────────────────────────
        // 스플래시에서는 대기, 다른 경로면 스플래시로 이동
        loading: () => isOnSplash ? null : AppRoutes.splash,
        // ── 인증 에러 ────────────────────────────────────────────────────
        error: (_, _) => isOnAuthPage ? null : AppRoutes.login,
      );
    },

    routes: [
      // ── 스플래시 (앱 시작 로딩, ShellRoute 밖) ──────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),

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
            path: AppRoutes.users,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UserManagementScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
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
//       _GoRouterNotifier: ref.listen(authStateProvider/currentUserProvider)
//                          변화를 ChangeNotifier로 전달.
//       appRouterProvider:
//         - initialLocation: /login → 앱 시작 시 항상 로그인 화면 먼저.
//         - redirect: Riverpod authStateProvider 기반으로 인증 상태 확인.
//           · 미로그인 + 보호 경로 → /login 강제.
//           · 로그인 + 인증 화면 → 역할 기반 분기
//             (admin → /dashboard, user/agent → /tickets).
//           · 로딩/에러 → /login에서 대기 (보호 경로 차단).
//         - /login, /signup은 ShellRoute 밖 (사이드바 없음).
// 사용: app.dart에서 ref.watch(appRouterProvider)로 MaterialApp.router에 전달.
