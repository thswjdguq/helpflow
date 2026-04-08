import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/design_system.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/admin/user_provider.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
import '../../features/tickets/ticket_provider.dart';
import '../../shared/models/ticket_model.dart';

/// 티켓 상세 화면
///
/// ticketId로 Firestore에서 티켓을 실시간 조회해 표시.
/// 역할별 허용 액션:
///   agent  → '처리 완료' 버튼 (in_progress → resolved)
///   admin  → 담당자 배정 버튼 + '종료' 버튼 (resolved → closed)
///   user   → 읽기 전용
class TicketDetailScreen extends ConsumerWidget {
  /// URL 경로 파라미터로 전달된 티켓 Firestore 문서 ID
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ticketId로 단일 티켓 실시간 구독
    final ticketAsync = ref.watch(_ticketDetailProvider(ticketId));
    final role = ref.watch(currentUserProvider).value?.role ?? UserRole.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ticketAsync.when(
        data: (ticket) {
          if (ticket == null) {
            return const Center(child: Text('티켓을 찾을 수 없습니다.'));
          }
          return _TicketDetailBody(ticket: ticket, role: role);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(color: HelpFlowColors.error),
          ),
        ),
      ),
    );
  }
}

// ── 단일 티켓 실시간 StreamProvider ─────────────────────────────────────────

/// ticketId로 단일 티켓을 실시간 구독하는 Family StreamProvider
final _ticketDetailProvider =
    StreamProvider.family<TicketModel?, String>((ref, ticketId) {
  final service = ref.read(ticketServiceProvider);
  return service.getTicketStream(ticketId);
});

// ── 티켓 상세 본문 ────────────────────────────────────────────────────────────

/// 티켓 정보 + 역할별 액션 버튼 표시
class _TicketDetailBody extends ConsumerWidget {
  final TicketModel ticket;
  final String role;

  const _TicketDetailBody({required this.ticket, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 상태·우선순위 배지 행 ────────────────────────────────────
          Row(
            children: [
              _InfoBadge(
                label: TicketStatus.label(ticket.status),
                color: _statusColor(ticket.status),
              ),
              const SizedBox(width: HelpFlowSpacing.sm),
              _InfoBadge(
                label: TicketPriority.label(ticket.priority),
                color: _priorityColor(ticket.priority),
              ),
              const SizedBox(width: HelpFlowSpacing.sm),
              _InfoBadge(
                label: TicketCategory.label(ticket.category),
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: HelpFlowSpacing.lg),

          // ── 제목 ────────────────────────────────────────────────────
          Text(
            ticket.title,
            style: AppTextStyles.pageTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: HelpFlowSpacing.sm),

          // ── 날짜 정보 ────────────────────────────────────────────────
          Text(
            '접수일: ${_formatDate(ticket.createdAt)}  |  수정일: ${_formatDate(ticket.updatedAt)}',
            style: AppTextStyles.bodySm.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: HelpFlowSpacing.xxxl),

          // ── 설명 ─────────────────────────────────────────────────────
          Text(
            '상세 내용',
            style: AppTextStyles.sectionTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: HelpFlowSpacing.sm),
          Text(
            ticket.description.isNotEmpty ? ticket.description : '(내용 없음)',
            style: AppTextStyles.bodyMd.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: HelpFlowSpacing.xxxl),

          // ── 담당자 정보 ──────────────────────────────────────────────
          Text(
            '담당자',
            style: AppTextStyles.sectionTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: HelpFlowSpacing.sm),
          Text(
            ticket.agentId ?? '미배정',
            style: AppTextStyles.bodyMd.copyWith(
              color: ticket.agentId != null
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: HelpFlowSpacing.xxl),

          // ── 역할별 액션 버튼 ─────────────────────────────────────────
          _ActionButtons(ticket: ticket, role: role),
        ],
      ),
    );
  }

  /// 상태 코드 → 색상
  Color _statusColor(String status) {
    switch (status) {
      case TicketStatus.newTicket:
        return const Color(0xFF1565C0);
      case TicketStatus.inProgress:
        return const Color(0xFFFB8C00);
      case TicketStatus.resolved:
        return const Color(0xFF43A047);
      case TicketStatus.closed:
        return const Color(0xFF757575);
      default:
        return const Color(0xFF1565C0);
    }
  }

  /// 우선순위 코드 → 색상
  Color _priorityColor(String priority) {
    switch (priority) {
      case TicketPriority.critical:
        return const Color(0xFFB71C1C);
      case TicketPriority.high:
        return const Color(0xFFE53935);
      case TicketPriority.medium:
        return const Color(0xFFFB8C00);
      default:
        return const Color(0xFF43A047);
    }
  }

  /// DateTime → 'YY.MM.DD' 형식 변환
  String _formatDate(DateTime dt) {
    final yy = dt.year.toString().substring(2);
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$yy.$mm.$dd';
  }
}

// ── 역할별 액션 버튼 ──────────────────────────────────────────────────────────

/// 역할과 티켓 상태에 따라 표시할 버튼 결정
///
/// agent  + in_progress → '처리 완료' 버튼
/// admin  + resolved    → '최종 종료' 버튼
/// admin  + agentId 없음 → '담당자 배정' 버튼 (agentId 직접 입력)
class _ActionButtons extends ConsumerStatefulWidget {
  final TicketModel ticket;
  final String role;

  const _ActionButtons({required this.ticket, required this.role});

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _isLoading = false;

  /// 상태 변경 공통 처리
  Future<void> _changeStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(ticketListProvider.notifier)
          .changeTicketStatus(widget.ticket.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상태가 "${TicketStatus.label(newStatus)}"(으)로 변경됐습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: HelpFlowColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// admin 전용: 담당자 배정 다이얼로그 (agent 목록 선택)
  Future<void> _showAssignDialog() async {
    // Riverpod에서 agent 목록 읽기
    final agentsAsync = ref.read(agentListProvider);
    final agents = agentsAsync.value ?? [];

    if (agents.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('등록된 담당자가 없습니다. 먼저 사용자 역할을 agent로 변경해주세요.')),
        );
      }
      return;
    }

    // 현재 배정된 담당자 기본 선택
    String? selectedUid = widget.ticket.agentId;
    if (selectedUid != null &&
        !agents.any((a) => a.uid == selectedUid)) {
      selectedUid = null;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('담당자 배정'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: agents.map((agent) {
                final isSelected = selectedUid == agent.uid;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.15),
                    child: Text(
                      agent.name.isNotEmpty ? agent.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  title: Text(agent.name),
                  subtitle: Text(
                    agent.email,
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF1565C0))
                      : null,
                  onTap: () => setState(() => selectedUid = agent.uid),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: selectedUid == null
                  ? null
                  : () => Navigator.pop(ctx, selectedUid),
              child: const Text('배정'),
            ),
          ],
        ),
      ),
    );

    if (result == null || result.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // agentId 업데이트 + 상태 in_progress로 변경
      final updated = widget.ticket.copyWith(
        agentId: result,
        status: TicketStatus.inProgress,
        updatedAt: DateTime.now(),
      );
      await ref.read(ticketListProvider.notifier).updateTicket(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('담당자가 배정됐습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: HelpFlowColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final role = widget.role;

    // closed 상태는 모든 역할에서 액션 불가
    if (ticket.status == TicketStatus.closed) {
      return Center(
        child: Text(
          '종료된 티켓입니다',
          style: AppTextStyles.bodyMd.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // agent: 처리 중 상태일 때 '처리 완료' 버튼
        if (role == UserRole.agent &&
            ticket.status == TicketStatus.inProgress)
          FilledButton(
            onPressed: _isLoading
                ? null
                : () => _changeStatus(TicketStatus.resolved),
            style: HelpFlowButtonStyles.filled,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('처리 완료'),
          ),

        // admin: 담당자 미배정 시 '담당자 배정' 버튼
        if (role == UserRole.admin && ticket.agentId == null) ...[
          FilledButton.tonal(
            onPressed: _isLoading ? null : _showAssignDialog,
            child: const Text('담당자 배정'),
          ),
          const SizedBox(height: HelpFlowSpacing.sm),
        ],

        // admin: resolved 상태일 때 '최종 종료' 버튼
        if (role == UserRole.admin &&
            ticket.status == TicketStatus.resolved)
          OutlinedButton(
            onPressed: _isLoading
                ? null
                : () => _changeStatus(TicketStatus.closed),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: HelpFlowColors.error),
              foregroundColor: HelpFlowColors.error,
            ),
            child: const Text('최종 종료'),
          ),
      ],
    );
  }
}

// ── 정보 배지 ────────────────────────────────────────────────────────────────

/// 상태/우선순위/카테고리 표시용 색상 배지
class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_detail_screen.dart
// 역할: 티켓 상세 화면. ticketId로 Firestore 실시간 구독.
//       상태·우선순위·카테고리 배지, 제목, 설명, 담당자, 날짜 표시.
//       역할별 액션:
//         agent + in_progress → '처리 완료' (resolved 변경)
//         admin + agentId 없음 → '담당자 배정' 다이얼로그
//         admin + resolved → '최종 종료' (closed 변경)
//       closed 상태 → 모든 액션 비활성화.
// 연관 파일: ticket_provider.dart, ticket_service.dart, ticket_model.dart
// ─────────────────────────────────────────────────────────────────────────────
