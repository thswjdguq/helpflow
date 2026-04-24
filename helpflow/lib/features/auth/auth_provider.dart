import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'user_model.dart';
import '../../shared/services/offline_cache_service.dart';

// ── AuthService 프로바이더 ────────────────────────────────────────────────────

/// AuthService 싱글턴 프로바이더
/// 로그인/회원가입/로그아웃 메서드 호출 시 ref.read(authServiceProvider)로 접근
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ── Firebase Auth 상태 스트림 프로바이더 ────────────────────────────────────

/// Firebase 인증 상태 스트림 프로바이더 (User?)
/// 로그인 시 User 방출, 로그아웃 시 null 방출
/// go_router의 redirect가 이 스트림을 구독해 화면 분기 처리
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// ── 현재 사용자 정보 Notifier ────────────────────────────────────────────────

/// 현재 로그인된 사용자의 UserModel 상태 관리
/// AsyncNotifierProvider 패턴 사용
class CurrentUserNotifier extends AsyncNotifier<UserModel?> {
  /// 초기 상태 빌드: Firebase Auth 현재 사용자를 Firestore에서 조회해 UserModel로 반환
  /// authStateProvider 변화 시 자동으로 재실행됨
  @override
  Future<UserModel?> build() async {
    // authStateProvider를 watch해서 로그인/로그아웃 변화에 반응
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) async {
        if (user == null) return null;
        // Firestore에서 역할(role) 포함 사용자 정보 조회
        final authService = ref.read(authServiceProvider);
        final firestoreUser = await authService.getUserFromFirestore(user.uid);
        if (firestoreUser != null) return firestoreUser;
        // Firestore 문서가 없으면 Firebase Auth 기본 정보로 대체
        return UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          role: UserRole.user,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      },
      loading: () => null,
      error: (_, _) => null,
    );
  }

  // ── 로그인 ────────────────────────────────────────────────────────────────

  /// 이메일/비밀번호로 로그인
  ///
  /// 성공 시: state = AsyncData(UserModel)
  /// 실패 시: state = AsyncError + 호출자에게 예외 rethrow
  ///          → signup_screen/login_screen의 catch 블록에서 에러 메시지 표시 가능
  Future<void> signIn(String email, String password) async {
    // 로딩 상태로 전환 (버튼 비활성화)
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);

    try {
      // AuthService를 통해 Firebase 로그인 처리
      final user = await authService.signInWithEmail(email, password);
      // 성공: 사용자 정보를 state에 저장
      state = AsyncData(user);
    } catch (e, st) {
      // 실패: 에러 상태로 전환 후 호출자에게 예외 전파
      // AsyncValue.guard()와 달리 rethrow를 사용해
      // login_screen.dart의 catch 블록이 실행되게 함
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // ── 회원가입 ──────────────────────────────────────────────────────────────

  /// 이메일/비밀번호/이름으로 회원가입
  ///
  /// 성공 시: state = AsyncData(UserModel) → authStateChanges가 자동으로 /dashboard 이동
  /// 실패 시: state = AsyncError + 호출자에게 예외 rethrow
  ///          → signup_screen.dart의 catch 블록에서 에러 메시지 표시 가능
  Future<void> signUp(String email, String password, String name) async {
    // 로딩 상태로 전환 (버튼 비활성화)
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);

    try {
      // AuthService를 통해 Firebase 계정 생성 + Firestore 저장
      final user = await authService.signUpWithEmail(email, password, name);
      // 성공: 신규 사용자 정보를 state에 저장
      state = AsyncData(user);
    } catch (e, st) {
      // 실패: 에러 상태로 전환 후 호출자에게 예외 전파
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // ── 로그아웃 ──────────────────────────────────────────────────────────────

  /// 현재 사용자 로그아웃
  /// 성공 시: state = AsyncData(null) → authStateChanges가 자동으로 /login 이동
  Future<void> signOut() async {
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);

    try {
      await authService.signOut();
      // 로그아웃 시 Hive 캐시 전체 삭제 (사용자 데이터 분리)
      await ref.read(offlineCacheServiceProvider).clearAll();
      // 로그아웃 성공: null로 초기화
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// CurrentUserNotifier 프로바이더
final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserModel?>(
  CurrentUserNotifier.new,
);

// ============================================================
// [파일 요약]
// 파일명: auth_provider.dart
// 역할: Firebase Auth 기반 인증 상태 Riverpod 관리
// 주요 클래스/함수:
//   - authServiceProvider: AuthService 싱글턴 제공
//   - authStateProvider: Firebase Auth 스트림 구독 (User? StreamProvider)
//   - CurrentUserNotifier: signIn/signUp/signOut 처리
//     · 에러 발생 시 state=AsyncError 설정 후 rethrow로 화면 catch 블록 실행 가능
// 연관 파일: auth_service.dart, login_screen.dart, signup_screen.dart, app_router.dart
// ============================================================
