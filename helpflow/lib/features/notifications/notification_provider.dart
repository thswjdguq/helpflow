import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/services/notification_service.dart';

// ── NotificationService Provider ─────────────────────────────────────────────

/// NotificationService 싱글턴 Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ── 알림 목록 Provider ────────────────────────────────────────────────────────

/// 현재 로그인 사용자의 알림 목록을 실시간으로 구독하는 StreamProvider
/// 최근 50개, createdAt 내림차순
final notificationListProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value([]);
  return ref.read(notificationServiceProvider).getNotifications(uid);
});

// ── 미읽음 카운트 Provider ─────────────────────────────────────────────────────

/// 현재 로그인 사용자의 미읽음 알림 수를 실시간으로 구독하는 StreamProvider
/// 상단 바 뱃지에서 사용
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(0);
  return ref.read(notificationServiceProvider).getUnreadCount(uid);
});

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: notification_provider.dart
// 역할: 인앱 알림 Riverpod Provider 모음.
//       notificationServiceProvider: NotificationService 싱글턴.
//       notificationListProvider: 현재 사용자 알림 목록 실시간 스트림.
//       unreadNotificationCountProvider: 미읽음 카운트 실시간 스트림.
// 연관 파일: notification_service.dart, notification_model.dart,
//            notifications_screen.dart, top_bar_widget.dart
// ─────────────────────────────────────────────────────────────────────────────
