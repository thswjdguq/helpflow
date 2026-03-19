import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'user_model.dart';

// ────────────────────────────────────────────────────────────────────────────
// AuthService 프로바이더
// ────────────────────────────────────────────────────────────────────────────

/// AuthService 싱글턴 프로바이더
/// 로그인/회원가입 메서드 호출 시 사용
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ────────────────────────────────────────────────────────────────────────────
// Firebase Auth 상태 스트림 프로바이더
// ────────────────────────────────────────────────────────────────────────────

/// Firebase 인증 상태 스트림 프로바이더
/// User? 스트림을 구독: 로그인 시 User, 로그아웃 시 null
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// ────────────────────────────────────────────────────────────────────────────
// 현재 사용자 정보 상태 관리 (AsyncNotifierProvider)
// ────────────────────────────────────────────────────────────────────────────

/// 현재 로그인된 사용자의 UserModel 상태 관리
/// AsyncNotifierProvider 패턴 사용
class CurrentUserNotifier extends AsyncNotifier<UserModel?> {
  /// 초기 상태: Firebase Auth 현재 사용자 확인
  @override
  Future<UserModel?> build() async {
    // authStateProvider 변화를 구독해서 자동 갱신
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) async {
        if (user == null) return null;

        // Firestore에서 사용자 정보 조회 시도
        try {
          // Firestore 조회는 signIn 시 처리됨
          // 여기서는 Firebase Auth 기본 정보만 UserModel로 래핑
          return UserModel(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            role: UserRole.user,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
          );
        } catch (_) {
          return null;
        }
      },
      loading: () => null,
      error: (_, _) => null,
    );
  }

  /// 로그인 처리
  ///
  /// [email] 이메일, [password] 비밀번호
  /// 성공 시 state를 UserModel로 갱신, 실패 시 AsyncError 설정
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);

    state = await AsyncValue.guard(() async {
      return await authService.signInWithEmail(email, password);
    });
  }

  /// 회원가입 처리
  ///
  /// [email] 이메일, [password] 비밀번호, [name] 이름
  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);

    state = await AsyncValue.guard(() async {
      return await authService.signUpWithEmail(email, password, name);
    });
  }

  /// 로그아웃 처리
  Future<void> signOut() async {
    state = const AsyncLoading();
    final authService = ref.read(authServiceProvider);

    try {
      await authService.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// CurrentUserNotifier 프로바이더
final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserModel?>(
  CurrentUserNotifier.new,
);

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: auth_provider.dart
// 역할: Riverpod 인증 상태 관리.
//       authServiceProvider - AuthService 싱글턴 제공.
//       authStateProvider - Firebase Auth 스트림 구독 (User? StreamProvider).
//       currentUserProvider - 현재 사용자 UserModel AsyncNotifierProvider.
//       CurrentUserNotifier - signIn/signUp/signOut 메서드로 상태 갱신.
