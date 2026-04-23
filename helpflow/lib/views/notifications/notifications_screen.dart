import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/notifications/notification_provider.dart';
import '../../shared/models/notification_model.dart';

/// 알림 목록 화면
///
/// 현재 로그인 사용자에게 수신된 알림 목록을 최신순으로 표시합니다.
/// 알림 탭 → 해당 티켓 상세 화면으로 이동.
/// "모두 읽음" 버튼으로 일괄 읽음 처리.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더 ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingLg,
                AppSizes.paddingLg,
                AppSizes.paddingMd,
                AppSizes.paddingMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '알림',
                      style: AppTextStyles.pageTitle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // 모두 읽음 버튼
                  notificationsAsync.maybeWhen(
                    data: (list) {
                      final hasUnread = list.any((n) => !n.isRead);
                      if (!hasUnread) return const SizedBox.shrink();
                      return TextButton.icon(
                        onPressed: uid == null
                            ? null
                            : () async {
                                await ref
                                    .read(notificationServiceProvider)
                                    .markAllAsRead(uid);
                              },
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('모두 읽음'),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── 알림 목록 ─────────────────────────────────────────────
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: AppSizes.paddingMd),
                          Text(
                            '새로운 알림이 없습니다',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMd,
                      vertical: AppSizes.paddingSm,
                    ),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSizes.paddingXs),
                    itemBuilder: (context, index) {
                      return _NotificationTile(
                        notification: notifications[index],
                        onTap: () async {
                          final n = notifications[index];
                          // 읽음 처리
                          if (!n.isRead) {
                            await ref
                                .read(notificationServiceProvider)
                                .markAsRead(n.id);
                          }
                          // 해당 티켓 상세로 이동
                          if (context.mounted && n.ticketId.isNotEmpty) {
                            context.go('/tickets/${n.ticketId}');
                          }
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    '알림을 불러오지 못했습니다',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 알림 타일 ────────────────────────────────────────────────────────────────

/// 개별 알림 항목 타일
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  /// 알림 타입에 따른 아이콘
  IconData _icon(String type) {
    switch (type) {
      case NotificationType.ticketAssigned:
        return Icons.assignment_ind_outlined;
      case NotificationType.ticketResolved:
        return Icons.check_circle_outline;
      case NotificationType.ticketClosed:
        return Icons.lock_outline;
      case NotificationType.newComment:
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  /// 알림 타입에 따른 색상
  Color _color(String type) {
    switch (type) {
      case NotificationType.ticketAssigned:
        return const Color(0xFF1565C0);
      case NotificationType.ticketResolved:
        return const Color(0xFF2E7D32);
      case NotificationType.ticketClosed:
        return const Color(0xFF757575);
      case NotificationType.newComment:
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF1565C0);
    }
  }

  /// 생성 시각을 사람이 읽기 쉬운 형식으로 변환
  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(notification.type);
    final isRead = notification.isRead;

    return Material(
      color: isRead
          ? Colors.transparent
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: AppSizes.paddingMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 타입 아이콘 ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(notification.type), color: color, size: 18),
              ),
              const SizedBox(width: AppSizes.paddingMd),

              // ── 내용 ──────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.ticketTitle,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: AppTextStyles.bodySm.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: notifications_screen.dart
// 역할: 인앱 알림 목록 화면.
//       notificationListProvider 구독 → 최신순 알림 표시.
//       _NotificationTile: 타입 아이콘/색상, 읽음/미읽음 스타일 분기, 시간 표시.
//       탭 → markAsRead() 후 해당 티켓 상세로 이동.
//       "모두 읽음" 버튼 → markAllAsRead().
// 연관 파일: notification_provider.dart, notification_model.dart
// ─────────────────────────────────────────────────────────────────────────────
