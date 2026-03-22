import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 역할 정의
/// user: 일반 사용자 (티켓 접수)
/// agent: 상담원 (티켓 처리)
/// admin: 관리자 (전체 관리)
class UserRole {
  UserRole._();

  static const String user = 'user';
  static const String agent = 'agent';
  static const String admin = 'admin';
}

/// HelpFlow 사용자 모델
/// Firebase Auth + Firestore 사용자 데이터를 통합 관리
class UserModel {
  /// Firebase Auth UID
  final String uid;

  /// 이메일 주소
  final String email;

  /// 표시 이름
  final String name;

  /// 역할: 'user' / 'agent' / 'admin'
  final String role;

  /// 계정 생성 시각
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  /// Firestore 문서 스냅샷에서 UserModel 생성
  ///
  /// [doc] Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? UserRole.user,
      // Firestore Timestamp → DateTime 변환
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// UserModel을 Firestore 저장용 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      // DateTime → Firestore Timestamp 변환
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 일부 필드만 변경한 새 인스턴스 반환 (불변 객체 패턴)
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role)';
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: user_model.dart
// 역할: HelpFlow 사용자 데이터 모델 정의.
//       uid, email, name, role, createdAt 필드 보유.
//       UserRole 상수 클래스로 역할 문자열 타입 안전하게 관리.
//       fromFirestore()로 Firestore 문서 역직렬화, toMap()으로 직렬화.
