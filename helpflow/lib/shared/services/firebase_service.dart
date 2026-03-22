import 'package:firebase_auth/firebase_auth.dart';

/// Firebase 공통 서비스
/// 에러 처리 등 Firebase 관련 공통 기능 제공
class FirebaseService {
  FirebaseService._(); // 인스턴스 생성 방지 (유틸 클래스)

  /// Firebase Auth 에러 코드를 사용자 친화적인 한글 메시지로 변환
  ///
  /// [e] Firebase에서 발생한 예외 객체
  /// 반환값: 사용자에게 보여줄 한글 에러 메시지
  static String handleFirebaseError(Object e) {
    // FirebaseAuthException 타입인 경우 에러 코드로 분기
    if (e is FirebaseAuthException) {
      return _translateAuthError(e.code);
    }

    // 그 외 Firebase 에러는 메시지 그대로 반환 (한글 폴백 포함)
    return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  /// FirebaseAuth 에러 코드를 한글 메시지로 변환
  ///
  /// [code] FirebaseAuthException.code 값
  static String _translateAuthError(String code) {
    switch (code) {
      // ── 로그인 관련 ──
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다. 관리자에게 문의하세요.';
      case 'too-many-requests':
        return '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요.';

      // ── 회원가입 관련 ──
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 합니다.';
      case 'invalid-email':
        return '올바른 이메일 형식이 아닙니다.';

      // ── 네트워크 관련 ──
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';

      // ── 세션 관련 ──
      case 'requires-recent-login':
        return '보안을 위해 다시 로그인해주세요.';

      // ── 기타 ──
      default:
        return '오류가 발생했습니다. ($code)';
    }
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: firebase_service.dart
// 역할: Firebase 공통 유틸 서비스.
//       handleFirebaseError()로 Firebase 예외를 한글 메시지로 변환.
//       FirebaseAuthException 에러 코드를 switch-case로 매핑.
//       인스턴스 생성 불가한 순수 유틸 클래스로 설계.
