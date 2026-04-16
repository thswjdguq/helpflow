import 'package:cloud_firestore/cloud_firestore.dart';

/// 댓글(공개) 및 내부 메모를 통합 관리하는 데이터 모델
///
/// Firestore 저장 위치: tickets/{ticketId}/comments/{commentId}
/// isInternal = true → 담당자·관리자만 볼 수 있는 내부 메모
/// isInternal = false → 접수자·담당자·관리자 모두 볼 수 있는 공개 댓글
class CommentModel {
  /// Firestore 문서 ID (자동 생성)
  final String id;

  /// 소속 티켓의 Firestore 문서 ID
  final String ticketId;

  /// 작성자의 Firebase Auth UID
  final String authorId;

  /// 작성자 표시 이름
  final String authorName;

  /// 작성자 역할: 'user' / 'agent' / 'admin'
  final String authorRole;

  /// 댓글 본문
  final String content;

  /// 내부 메모 여부 (true → 담당자·관리자만 열람 가능)
  final bool isInternal;

  /// 댓글 작성 시각
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.ticketId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.isInternal,
    required this.createdAt,
  });

  /// Firestore DocumentSnapshot → CommentModel 역직렬화
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      ticketId: data['ticketId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '(알 수 없음)',
      authorRole: data['authorRole'] as String? ?? 'user',
      content: data['content'] as String? ?? '',
      isInternal: data['isInternal'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// CommentModel → Firestore 저장용 Map 직렬화
  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'content': content,
      'isInternal': isInternal,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// 역할 코드 → 한글 표시 레이블 변환 (댓글 UI 전용)
String commentRoleLabel(String role) {
  switch (role) {
    case 'admin':
      return '관리자';
    case 'agent':
      return '담당자';
    default:
      return '직원';
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: comment_model.dart
// 역할: 티켓 댓글 및 내부 메모 데이터 모델.
//       Firestore 경로: tickets/{ticketId}/comments/{commentId}
//       isInternal: true → 담당자/관리자 전용 내부 메모
//       fromFirestore() / toMap() 직렬화 지원.
//       commentRoleLabel(): 역할 코드 → 한글 레이블.
// 연관 파일: comment_service.dart, comment_provider.dart, ticket_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
