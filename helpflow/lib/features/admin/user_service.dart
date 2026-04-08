import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/user_model.dart';

/// 사용자 관리 서비스 (admin 전용)
///
/// Firestore users 컬렉션의 목록 조회 및 역할 변경 기능 제공.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection('users');

  // ── 전체 사용자 조회 ──────────────────────────────────────────────────────

  /// 전체 사용자 목록을 실시간으로 구독 (가입일 내림차순)
  Stream<List<UserModel>> getUsers() {
    return _usersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // ── 담당자(agent) 목록 조회 ───────────────────────────────────────────────

  /// role == 'agent'인 사용자만 실시간으로 구독
  /// 담당자 배정 드롭다운에서 사용
  Stream<List<UserModel>> getAgents() {
    return _usersRef
        .where('role', isEqualTo: UserRole.agent)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // ── 역할 변경 ─────────────────────────────────────────────────────────────

  /// 특정 사용자의 역할을 변경합니다.
  ///
  /// [uid]     변경 대상 사용자의 Firebase Auth UID
  /// [newRole] 새로운 역할 ('user' | 'agent' | 'admin')
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _usersRef.doc(uid).update({'role': newRole});
    } on FirebaseException catch (e) {
      throw Exception('역할 변경 중 오류가 발생했습니다. (${e.code})');
    } catch (_) {
      throw Exception('역할 변경 중 오류가 발생했습니다.');
    }
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: user_service.dart
// 역할: admin 전용 사용자 관리 Firestore 서비스.
//       getUsers(): 전체 사용자 실시간 스트림 (가입일 내림차순).
//       getAgents(): role == 'agent' 사용자 실시간 스트림 (담당자 배정용).
//       updateUserRole(): 특정 사용자 역할 변경.
// 연관 파일: user_provider.dart, user_management_screen.dart, ticket_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
