import 'package:cloud_firestore/cloud_firestore.dart';

// ── 알림 타입 상수 ────────────────────────────────────────────────────────────

/// 인앱 알림 타입 상수
class NotificationType {
  NotificationType._();

  /// 티켓이 담당자(agent)에게 배정됨
  static const String ticketAssigned = 'ticket_assigned';

  /// 티켓 상태가 처리 완료(resolved)로 변경됨 → user에게 알림
  static const String ticketResolved = 'ticket_resolved';

  /// 티켓이 최종 종료(closed)됨 → user에게 알림
  static const String ticketClosed = 'ticket_closed';

  /// 상대방이 댓글을 남김 → 관련 사용자에게 알림
  static const String newComment = 'new_comment';

  /// 타입 코드 → 사람이 읽기 쉬운 레이블
  static String label(String type) {
    switch (type) {
      case ticketAssigned:
        return '티켓 배정';
      case ticketResolved:
        return '처리 완료';
      case ticketClosed:
        return '티켓 종료';
      case newComment:
        return '새 댓글';
      default:
        return '알림';
    }
  }

  /// 타입에 따른 아이콘 코드포인트 (IconData 없이 사용 가능)
  static String icon(String type) {
    switch (type) {
      case ticketAssigned:
        return 'assignment_ind';
      case ticketResolved:
        return 'check_circle';
      case ticketClosed:
        return 'lock';
      case newComment:
        return 'chat_bubble';
      default:
        return 'notifications';
    }
  }
}

// ── 알림 데이터 모델 ──────────────────────────────────────────────────────────

/// 인앱 알림 문서 모델
///
/// Firestore 컬렉션: 'notifications'
/// 특정 사용자(recipientId)를 대상으로 하는 알림을 저장합니다.
class NotificationModel {
  /// Firestore 문서 ID (자동 생성)
  final String id;

  /// 알림을 받는 사용자의 UID
  final String recipientId;

  /// 알림 타입 (NotificationType 상수 사용)
  final String type;

  /// 관련 티켓 ID
  final String ticketId;

  /// 관련 티켓 제목 (조회 없이 바로 표시용)
  final String ticketTitle;

  /// 알림 본문 메시지
  final String message;

  /// 읽음 여부
  final bool isRead;

  /// 알림 생성 시각
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.ticketId,
    required this.ticketTitle,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  /// Firestore DocumentSnapshot에서 NotificationModel 생성 (역직렬화)
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      ticketId: data['ticketId'] as String? ?? '',
      ticketTitle: data['ticketTitle'] as String? ?? '',
      message: data['message'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// NotificationModel을 Firestore 저장용 Map으로 변환 (직렬화)
  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'type': type,
      'ticketId': ticketId,
      'ticketTitle': ticketTitle,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// isRead만 변경한 새 인스턴스 반환
  NotificationModel markRead() {
    return NotificationModel(
      id: id,
      recipientId: recipientId,
      type: type,
      ticketId: ticketId,
      ticketTitle: ticketTitle,
      message: message,
      isRead: true,
      createdAt: createdAt,
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: notification_model.dart
// 역할: 인앱 알림 데이터 모델.
//       NotificationType: ticket_assigned / ticket_resolved / ticket_closed /
//         new_comment 타입 상수 + label() + icon() 헬퍼.
//       NotificationModel: recipientId, type, ticketId, ticketTitle,
//         message, isRead, createdAt 필드. Firestore 직렬화/역직렬화.
// 연관 파일: notification_service.dart, notification_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
