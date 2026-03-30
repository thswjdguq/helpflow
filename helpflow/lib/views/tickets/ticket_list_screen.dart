import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
import '../../features/tickets/ticket_provider.dart';
import '../../shared/models/ticket_model.dart';
import '../../shared/widgets/empty_state_widget.dart';

/// 티켓 목록 화면
///
/// 역할에 따라 다른 데이터 구독:
///   admin / agent → ticketListStreamProvider (전체 티켓, createdAt 내림차순)
///   user          → myTicketListStreamProvider (내 티켓만)
class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 사용자 역할 조회 (로딩 중이면 기본 user로 처리)
    final role = ref.watch(currentUserProvider).value?.role ?? UserRole.user;

    // 역할에 따라 Stream Provider 선택
    final isAdminOrAgent =
        role == UserRole.admin || role == UserRole.agent;
    final ticketsAsync = isAdminOrAgent
        ? ref.watch(ticketListStreamProvider)
        : ref.watch(myTicketListStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ticketsAsync.when(
        // ── 데이터 로드 완료 ─────────────────────────────────────────────
        data: (tickets) {
          if (tickets.isEmpty) {
            // 빈 상태: 새 티켓 생성 안내
            return EmptyStateWidget(
              icon: Icons.confirmation_number_outlined,
              message: AppStrings.emptyTickets,
              subtitle: AppStrings.emptyTicketsSubtitle,
              action: FilledButton.icon(
                onPressed: () => context.go(AppRoutes.ticketNew),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.btnNewTicket),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            itemCount: tickets.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSizes.paddingSm),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _TicketCard(
                ticket: ticket,
                onTap: () => context.go('/tickets/${ticket.id}'),
              );
            },
          );
        },
        // ── 로딩 중 ──────────────────────────────────────────────────────
        loading: () => const Center(child: CircularProgressIndicator()),
        // ── 에러 ─────────────────────────────────────────────────────────
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: AppTextStyles.bodyMd.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 티켓 카드 ────────────────────────────────────────────────────────────────

/// 개별 티켓을 카드 형태로 표시
/// 상태 배지, 우선순위 배지, 제목, 설명(최대 2줄), 카테고리, 날짜 포함
class _TicketCard extends StatelessWidget {
  /// 표시할 티켓 모델
  final TicketModel ticket;

  /// 카드 탭 콜백 (상세 화면 이동)
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  /// DateTime → 'YY.MM.DD' 형식 변환
  String _formatDate(DateTime dt) {
    final yy = dt.year.toString().substring(2);
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$yy.$mm.$dd';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 상단: 상태·우선순위 배지 + 날짜 ────────────────────────
              Row(
                children: [
                  _StatusBadge(status: ticket.status),
                  const SizedBox(width: AppSizes.paddingXs),
                  _PriorityBadge(priority: ticket.priority),
                  const Spacer(),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: AppTextStyles.bodySm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSm),

              // ── 제목 ──────────────────────────────────────────────────
              Text(
                ticket.title,
                style: AppTextStyles.cardTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // ── 설명 (있는 경우만 표시) ────────────────────────────────
              if (ticket.description.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingXs),
                Text(
                  ticket.description,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppSizes.paddingSm),

              // ── 카테고리 ──────────────────────────────────────────────
              Text(
                TicketCategory.label(ticket.category),
                style: AppTextStyles.bodySm.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 상태 배지 ────────────────────────────────────────────────────────────────

/// 티켓 상태(new/in_progress/resolved/closed)를 색상 배지로 표시
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _badgeColor() {
    switch (status) {
      case TicketStatus.newTicket:
        return const Color(0xFF1565C0); // 파랑 — 신규
      case TicketStatus.inProgress:
        return const Color(0xFFFB8C00); // 주황 — 처리 중
      case TicketStatus.resolved:
        return const Color(0xFF43A047); // 초록 — 해결 완료
      case TicketStatus.closed:
        return const Color(0xFF757575); // 회색 — 종료
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        TicketStatus.label(status),
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}

// ── 우선순위 배지 ─────────────────────────────────────────────────────────────

/// 티켓 우선순위(low/medium/high/critical)를 색상 배지로 표시
class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  Color _badgeColor() {
    switch (priority) {
      case TicketPriority.critical:
        return const Color(0xFFB71C1C); // 짙은 빨강 — 긴급
      case TicketPriority.high:
        return const Color(0xFFE53935); // 빨강 — 높음
      case TicketPriority.medium:
        return const Color(0xFFFB8C00); // 주황 — 보통
      default:
        return const Color(0xFF43A047); // 초록 — 낮음
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        TicketPriority.label(priority),
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_list_screen.dart
// 역할: 티켓 목록 화면. 역할별 실시간 Firestore 스트림 구독.
//       admin/agent → ticketListStreamProvider (전체 티켓).
//       user        → myTicketListStreamProvider (본인 티켓).
//       빈 상태: EmptyStateWidget + 새 티켓 생성 버튼.
//       _TicketCard: 상태·우선순위 배지, 제목, 설명, 카테고리, 날짜.
// 연관 파일: ticket_provider.dart, ticket_model.dart, auth_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
