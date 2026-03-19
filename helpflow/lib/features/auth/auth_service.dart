import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';
import '../../shared/services/firebase_service.dart';

/// 인증 서비스
/// Firebase Auth + Firestore를 이용한 로그인/회원가입/로그아웃 처리
class AuthService {
  /// Firebase Auth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자 컬렉션 참조
  CollectionReference get _usersRef => _firestore.collection('users');

  // ────────────────────────────────────────────────────────────────────────────
  // 인증 상태
  // ────────────────────────────────────────────────────────────────────────────

  /// 현재 로그인된 Firebase 사용자 반환 (없으면 null)
  User? getCurrentUser() => _auth.currentUser;

  /// 인증 상태 변화 스트림 (로그인/로그아웃 감지용)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ────────────────────────────────────────────────────────────────────────────
  // 로그인
  // ────────────────────────────────────────────────────────────────────────────

  /// 이메일/비밀번호로 로그인
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  /// 반환값: 로그인된 [UserModel]
  /// 실패 시: 한글 메시지로 [Exception] throw
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      // Firebase Auth 로그인
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Firestore에서 사용자 추가 정보 조회
      final doc = await _usersRef.doc(uid).get();

      if (!doc.exists) {
        // Firestore 문서가 없으면 기본 UserModel 반환
        return UserModel(
          uid: uid,
          email: email.trim(),
          name: credential.user?.displayName ?? '',
          role: UserRole.user,
          createdAt: DateTime.now(),
        );
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      // Firebase 에러를 한글 메시지로 변환해서 다시 throw
      throw Exception(FirebaseService.handleFirebaseError(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 회원가입
  // ────────────────────────────────────────────────────────────────────────────

  /// 이메일/비밀번호로 회원가입
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  /// [name] 표시 이름
  /// 반환값: 생성된 [UserModel]
  /// 실패 시: 한글 메시지로 [Exception] throw
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Firebase Auth 계정 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // displayName 설정
      await credential.user!.updateDisplayName(name.trim());

      // Firestore에 사용자 문서 저장
      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        role: UserRole.user,
        createdAt: DateTime.now(),
      );

      await _usersRef.doc(newUser.uid).set(newUser.toMap());

      return newUser;
    } catch (e) {
      throw Exception(FirebaseService.handleFirebaseError(e));
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 로그아웃
  // ────────────────────────────────────────────────────────────────────────────

  /// 현재 사용자 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception(FirebaseService.handleFirebaseError(e));
    }
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: auth_service.dart
// 역할: Firebase Auth + Firestore 기반 인증 서비스.
//       signInWithEmail() - 이메일 로그인 후 Firestore에서 UserModel 반환.
//       signUpWithEmail() - 계정 생성 후 Firestore에 사용자 문서 저장.
//       signOut() - 로그아웃.
//       모든 에러는 FirebaseService.handleFirebaseError()로 한글 변환 후 throw.
