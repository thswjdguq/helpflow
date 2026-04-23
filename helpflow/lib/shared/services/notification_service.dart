import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

/// 인앱 알림 Firestore CRUD 서비스
///
/// 컬렉션: notifications
/// 알림 생성, 목록 조회, 읽음 처리를 담당합니다.
class NotificationService {
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection('notifications');

  // ── 조회 ─────────────────────────────────────────────────────────────────

  /// 특정 사용자의 알림 목록을 실시간으로 구독 (최근 50개, 시간 역순)
  Stream<List<NotificationModel>> getNotifications(String recipientId) {
    return _ref
        .where('recipientId', isEqualTo: recipientId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// 특정 사용자의 미읽음 알림 수를 실시간으로 구독
  Stream<int> getUnreadCount(String recipientId) {
    return _ref
        .where('recipientId', isEqualTo: recipientId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ── 생성 ─────────────────────────────────────────────────────────────────

  /// 새 알림 문서 생성
  Future<void> createNotification(NotificationModel notification) async {
    await _ref.add(notification.toMap());
  }

  // ── 읽음 처리 ─────────────────────────────────────────────────────────────

  /// 단일 알림을 읽음으로 표시
  Future<void> markAsRead(String notificationId) async {
    await _ref.doc(notificationId).update({'isRead': true});
  }

  /// 특정 사용자의 모든 알림을 읽음으로 표시
  Future<void> markAllAsRead(String recipientId) async {
    final unread = await _ref
        .where('recipientId', isEqualTo: recipientId)
        .where('isRead', isEqualTo: false)
        .get();

    // Firestore 일괄 업데이트 (WriteBatch 사용)
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── 삭제 ─────────────────────────────────────────────────────────────────

  /// 단일 알림 삭제
  Future<void> deleteNotification(String notificationId) async {
    await _ref.doc(notificationId).delete();
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: notification_service.dart
// 역할: 인앱 알림 Firestore 서비스.
//       getNotifications(uid): 실시간 알림 목록 스트림 (최근 50개).
//       getUnreadCount(uid): 미읽음 카운트 실시간 스트림.
//       createNotification(model): 알림 문서 생성.
//       markAsRead(id): 단일 읽음 처리.
//       markAllAsRead(uid): 일괄 읽음 처리 (WriteBatch).
// 연관 파일: notification_model.dart, notification_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
