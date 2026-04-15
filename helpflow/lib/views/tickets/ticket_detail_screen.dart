import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/design_system.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
import '../../features/tickets/comment_provider.dart';
import '../../features/tickets/ticket_provider.dart';
import '../../features/admin/user_provider.dart';
import '../../shared/models/comment_model.dart';
import '../../shared/models/ticket_model.dart';

/// 티켓 상세 화면
///
/// ticketId로 Firestore 실시간 구독. 역할별 UX:
///   user  → 읽기 + 공개 댓글 작성
///   agent → 읽기 + 공개 댓글 + 내부 메모 + '처리 완료' 버튼
///   admin → 전체 + 담당자 배정 + '최종 종료' 버튼
class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(_ticketDetailProvider(ticketId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ticketAsync.when(
        data: (ticket) {
          if (ticket == null) {
            return const Center(child: Text('티켓을 찾을 수 없습니다.'));
          }
          return _TicketDetailContent(
            ticket: ticket,
            currentUser: currentUser,
          );
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

final _ticketDetailProvider =
    StreamProvider.family<TicketModel?, String>((ref, ticketId) {
  return ref.read(ticketServiceProvider).getTicketStream(ticketId);
});

// ── 티켓 상세 전체 레이아웃 ──────────────────────────────────────────────────

/// 스크롤 영역(티켓 정보 + 댓글) + 하단 고정(댓글 입력 + 액션 버튼) 구조
class _TicketDetailContent extends ConsumerStatefulWidget {
  final TicketModel ticket;
  final UserModel? currentUser;

  const _TicketDetailContent({
    required this.ticket,
    required this.currentUser,
  });

  @override
  ConsumerState<_TicketDetailContent> createState() =>
      _TicketDetailContentState();
}

class _TicketDetailContentState extends ConsumerState<_TicketDetailContent> {
  /// 댓글 입력 컨트롤러
  final _commentController = TextEditingController();

  /// 내부 메모 여부 토글 (agent/admin 전용)
  bool _isInternal = false;

  /// 댓글 전송 중 로딩 상태
  bool _isSending = false;

  /// 액션 버튼 로딩 상태
  bool _isActing = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// 댓글 전송 처리
  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = widget.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);
    try {
      final comment = CommentModel(
        id: '',
        ticketId: widget.ticket.id,
        authorId: user.uid,
        authorName: user.name.isNotEmpty ? user.name : user.email,
        authorRole: user.role,
        content: content,
        isInternal: _isInternal,
        createdAt: DateTime.now(),
      );
      await ref.read(commentServiceProvider).addComment(comment);
      _commentController.clear();
      // 내부 메모 토글은 전송 후 초기화
      if (_isInternal) setState(() => _isInternal = false);
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
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// 상태 변경 공통 처리
  Future<void> _changeStatus(String newStatus) async {
    setState(() => _isActing = true);
    try {
      await ref
          .read(ticketListProvider.notifier)
          .changeTicketStatus(widget.ticket.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('상태가 "${TicketStatus.label(newStatus)}"(으)로 변경됐습니다'),
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
      if (mounted) setState(() => _isActing = false);
    }
  }

  /// admin 전용: 담당자 배정 다이얼로그
  Future<void> _showAssignDialog() async {
    final agentsAsync = ref.read(agentListProvider);
    final agents = agentsAsync.value ?? [];

    if (agents.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('등록된 담당자가 없습니다. 사용자 관리에서 역할을 agent로 변경해주세요.')),
        );
      }
      return;
    }

    String? selectedUid = widget.ticket.agentId;
    if (selectedUid != null && !agents.any((a) => a.uid == selectedUid)) {
      selectedUid = null;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
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
                    backgroundColor:
                        const Color(0xFF1565C0).withValues(alpha: 0.15),
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
                  subtitle:
                      Text(agent.email, style: const TextStyle(fontSize: 11)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF1565C0))
                      : null,
                  onTap: () => setDlgState(() => selectedUid = agent.uid),
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

    setState(() => _isActing = true);
    try {
      final updated = widget.ticket.copyWith(
        agentId: result,
        status: TicketStatus.inProgress,
        updatedAt: DateTime.now(),
      );
      await ref.read(ticketListProvider.notifier).updateTicket(updated);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('담당자가 배정됐습니다')));
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
      if (mounted) setState(() => _isActing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final role = widget.currentUser?.role ?? UserRole.user;
    final canSeeInternal =
        role == UserRole.agent || role == UserRole.admin;

    return Column(
      children: [
        // ── 스크롤 영역: 티켓 정보 + 댓글 ─────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상태·우선순위·카테고리 배지
                _BadgeRow(ticket: ticket),
                const SizedBox(height: HelpFlowSpacing.lg),

                // 제목
                Text(
                  ticket.title,
                  style: AppTextStyles.pageTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: HelpFlowSpacing.sm),

                // 날짜 정보
                _DateInfo(ticket: ticket),
                const Divider(height: HelpFlowSpacing.xxxl),

                // 상세 내용
                _SectionLabel(label: '상세 내용'),
                const SizedBox(height: HelpFlowSpacing.sm),
                Text(
                  ticket.description.isNotEmpty
                      ? ticket.description
                      : '(내용 없음)',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: HelpFlowSpacing.xxxl),

                // 첨부 이미지 (있을 때만)
                if (ticket.imageUrls.isNotEmpty) ...[
                  _ImageGallery(imageUrls: ticket.imageUrls),
                  const Divider(height: HelpFlowSpacing.xxxl),
                ],

                // 접수 정보 (담당자 + 접수자)
                _TicketMetaInfo(ticket: ticket),
                const Divider(height: HelpFlowSpacing.xxxl),

                // 댓글 섹션
                _CommentsSection(
                  ticketId: ticket.id,
                  canSeeInternal: canSeeInternal,
                  currentUserId: widget.currentUser?.uid ?? '',
                  role: role,
                  ref: ref,
                ),

                // 하단 입력창 높이만큼 여백
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // ── 하단 고정: 역할별 액션 버튼 ──────────────────────────────────
        if (ticket.status != TicketStatus.closed)
          _ActionBar(
            ticket: ticket,
            role: role,
            isLoading: _isActing,
            onChangeStatus: _changeStatus,
            onAssign: _showAssignDialog,
          ),

        // ── 하단 고정: 댓글 입력창 ───────────────────────────────────────
        _CommentInputBar(
          controller: _commentController,
          isInternal: _isInternal,
          canToggleInternal: canSeeInternal,
          isSending: _isSending,
          onToggleInternal: () => setState(() => _isInternal = !_isInternal),
          onSend: _sendComment,
        ),
      ],
    );
  }
}

// ── 배지 행 ──────────────────────────────────────────────────────────────────

class _BadgeRow extends StatelessWidget {
  final TicketModel ticket;
  const _BadgeRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: HelpFlowSpacing.sm,
      runSpacing: HelpFlowSpacing.xs,
      children: [
        _Chip(
          label: TicketStatus.label(ticket.status),
          color: _statusColor(ticket.status),
        ),
        _Chip(
          label: TicketPriority.label(ticket.priority),
          color: _priorityColor(ticket.priority),
        ),
        _Chip(
          label: TicketCategory.label(ticket.category),
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case TicketStatus.newTicket:
        return const Color(0xFF1565C0);
      case TicketStatus.inProgress:
        return const Color(0xFFFB8C00);
      case TicketStatus.resolved:
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF757575);
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
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
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.badge.copyWith(color: color)),
    );
  }
}

// ── 날짜 정보 ────────────────────────────────────────────────────────────────

class _DateInfo extends StatelessWidget {
  final TicketModel ticket;
  const _DateInfo({required this.ticket});

  String _fmt(DateTime dt) {
    final yy = dt.year.toString().substring(2);
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$yy.$mm.$dd $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '접수: ${_fmt(ticket.createdAt)}  |  수정: ${_fmt(ticket.updatedAt)}',
      style: AppTextStyles.bodySm.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ── 섹션 레이블 ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.sectionTitle.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ── 첨부 이미지 갤러리 ───────────────────────────────────────────────────────

/// 첨부 이미지를 가로 스크롤로 나열, 탭하면 전체화면 다이얼로그로 확대
class _ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  const _ImageGallery({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: '첨부 이미지 (${imageUrls.length}장)'),
        const SizedBox(height: HelpFlowSpacing.sm),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = imageUrls[index];
              return GestureDetector(
                onTap: () => _showFullImage(context, url, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 100,
                      height: 100,
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 이미지 전체화면 다이얼로그
  void _showFullImage(BuildContext context, String url, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image, color: Colors.white54),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 12,
              child: Text(
                '${index + 1} / ${imageUrls.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 티켓 메타 정보 (접수자 + 담당자) ─────────────────────────────────────────

class _TicketMetaInfo extends StatelessWidget {
  final TicketModel ticket;
  const _TicketMetaInfo({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reporterDisplay = ticket.reporterName.isNotEmpty
        ? ticket.reporterName
        : ticket.reporterId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetaItem(
                icon: Icons.person_outline,
                label: '접수자',
                value: reporterDisplay,
              ),
            ),
            Expanded(
              child: _MetaItem(
                icon: Icons.support_agent_outlined,
                label: '담당자',
                value: ticket.agentId != null ? '배정됨' : '미배정',
                valueColor: ticket.agentId != null
                    ? const Color(0xFF1565C0)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 댓글 섹션 ────────────────────────────────────────────────────────────────

/// ticketId로 댓글 스트림을 구독해 댓글 목록 표시
/// canSeeInternal: false인 경우(user) isInternal=true 댓글을 숨김
class _CommentsSection extends StatelessWidget {
  final String ticketId;
  final bool canSeeInternal;
  final String currentUserId;
  final String role;
  final WidgetRef ref;

  const _CommentsSection({
    required this.ticketId,
    required this.canSeeInternal,
    required this.currentUserId,
    required this.role,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentListProvider(ticketId));

    return commentsAsync.when(
      data: (allComments) {
        // user는 내부 메모 숨김
        final comments = canSeeInternal
            ? allComments
            : allComments.where((c) => !c.isInternal).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SectionLabel(label: '대화'),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${comments.length}',
                    style: AppTextStyles.badge.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: HelpFlowSpacing.md),

            if (comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '아직 댓글이 없습니다. 첫 번째 댓글을 남겨보세요.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: HelpFlowSpacing.md),
                itemBuilder: (context, index) => _CommentBubble(
                  comment: comments[index],
                  isMyComment: comments[index].authorId == currentUserId,
                  canDelete: role == UserRole.admin ||
                      comments[index].authorId == currentUserId,
                  onDelete: () => ref
                      .read(commentServiceProvider)
                      .deleteComment(ticketId, comments[index].id),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

// ── 댓글 말풍선 ──────────────────────────────────────────────────────────────

/// 개별 댓글 표시 위젯
/// 내 댓글은 오른쪽 정렬, 상대방은 왼쪽 정렬
/// 내부 메모는 amber 배경 + '내부 메모' 배지
class _CommentBubble extends StatelessWidget {
  final CommentModel comment;
  final bool isMyComment;
  final bool canDelete;
  final VoidCallback onDelete;

  const _CommentBubble({
    required this.comment,
    required this.isMyComment,
    required this.canDelete,
    required this.onDelete,
  });

  String _formatTime(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$mm/$dd $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInternal = comment.isInternal;

    // 내부 메모: 특별 스타일 (정렬 무관)
    if (isInternal) {
      return _InternalNoteBubble(
        comment: comment,
        canDelete: canDelete,
        onDelete: onDelete,
        formatTime: _formatTime,
      );
    }

    // 공개 댓글: 내 댓글 우측, 상대방 좌측
    return Row(
      mainAxisAlignment:
          isMyComment ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상대방: 아바타 왼쪽에
        if (!isMyComment) ...[
          _Avatar(name: comment.authorName, role: comment.authorRole),
          const SizedBox(width: HelpFlowSpacing.sm),
        ],

        Flexible(
          child: Column(
            crossAxisAlignment: isMyComment
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // 작성자 정보
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMyComment) ...[
                    Text(
                      comment.authorName,
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _RoleBadge(role: comment.authorRole),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(comment.createdAt),
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    Text(
                      _formatTime(comment.createdAt),
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),

              // 말풍선
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMyComment
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isMyComment
                        ? const Radius.circular(12)
                        : const Radius.circular(2),
                    bottomRight: isMyComment
                        ? const Radius.circular(2)
                        : const Radius.circular(12),
                  ),
                ),
                child: Text(
                  comment.content,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: isMyComment
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),

              // 삭제 버튼 (권한 있을 때)
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '삭제',
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 내 댓글: 아바타 오른쪽에
        if (isMyComment) ...[
          const SizedBox(width: HelpFlowSpacing.sm),
          _Avatar(name: comment.authorName, role: comment.authorRole),
        ],
      ],
    );
  }
}

/// 내부 메모 전용 표시 (amber 배경, 자물쇠 아이콘)
class _InternalNoteBubble extends StatelessWidget {
  final CommentModel comment;
  final bool canDelete;
  final VoidCallback onDelete;
  final String Function(DateTime) formatTime;

  const _InternalNoteBubble({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 14, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text(
                '내부 메모',
                style: AppTextStyles.bodySm.copyWith(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.authorName,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              _RoleBadge(role: comment.authorRole),
              const Spacer(),
              Text(
                formatTime(comment.createdAt),
                style: AppTextStyles.bodySm.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Text(
                    '삭제',
                    style: AppTextStyles.bodySm.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(comment.content, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}

/// 작성자 아바타 (이름 첫 글자)
class _Avatar extends StatelessWidget {
  final String name;
  final String role;

  const _Avatar({required this.name, required this.role});

  Color _roleColor(String r) {
    switch (r) {
      case 'admin':
        return const Color(0xFFB71C1C);
      case 'agent':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF43A047);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// 역할 뱃지 (담당자/관리자/직원)
class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final label = commentRoleLabel(role);
    Color color;
    switch (role) {
      case 'admin':
        color = const Color(0xFFB71C1C);
        break;
      case 'agent':
        color = const Color(0xFF1565C0);
        break;
      default:
        color = const Color(0xFF43A047);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

// ── 역할별 액션 버튼 바 ───────────────────────────────────────────────────────

/// 티켓 상태 변경 버튼을 역할에 따라 표시
class _ActionBar extends StatelessWidget {
  final TicketModel ticket;
  final String role;
  final bool isLoading;
  final Future<void> Function(String) onChangeStatus;
  final Future<void> Function() onAssign;

  const _ActionBar({
    required this.ticket,
    required this.role,
    required this.isLoading,
    required this.onChangeStatus,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // agent + 처리 중 → 처리 완료 버튼
    final showResolve =
        role == UserRole.agent && ticket.status == TicketStatus.inProgress;

    // admin + 담당자 없음 → 담당자 배정 버튼
    final showAssign =
        role == UserRole.admin && ticket.agentId == null;

    // admin + resolved → 최종 종료 버튼
    final showClose =
        role == UserRole.admin && ticket.status == TicketStatus.resolved;

    if (!showResolve && !showAssign && !showClose) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          if (showAssign) ...[
            Expanded(
              child: FilledButton.tonal(
                onPressed: isLoading ? null : onAssign,
                child: const Text('담당자 배정'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingSm),
          ],
          if (showResolve)
            Expanded(
              child: FilledButton(
                onPressed: isLoading
                    ? null
                    : () => onChangeStatus(TicketStatus.resolved),
                style: HelpFlowButtonStyles.filled,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('처리 완료'),
              ),
            ),
          if (showClose)
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () => onChangeStatus(TicketStatus.closed),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: HelpFlowColors.error),
                  foregroundColor: HelpFlowColors.error,
                ),
                child: const Text('최종 종료'),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 댓글 입력창 ──────────────────────────────────────────────────────────────

/// 하단 고정 댓글 입력창
/// agent/admin은 '내부 메모' 토글 표시
class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isInternal;
  final bool canToggleInternal;
  final bool isSending;
  final VoidCallback onToggleInternal;
  final Future<void> Function() onSend;

  const _CommentInputBar({
    required this.controller,
    required this.isInternal,
    required this.canToggleInternal,
    required this.isSending,
    required this.onToggleInternal,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingMd,
        right: AppSizes.paddingMd,
        top: AppSizes.paddingSm,
        bottom: AppSizes.paddingSm + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isInternal
            ? const Color(0xFFFFF8E1)
            : theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 내부 메모 활성 안내
          if (isInternal)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline,
                      size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                    '내부 메모 — 담당자·관리자만 볼 수 있습니다',
                    style: AppTextStyles.bodySm.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              // 내부 메모 토글 버튼 (agent/admin 전용)
              if (canToggleInternal) ...[
                Tooltip(
                  message: '내부 메모로 전환',
                  child: IconButton(
                    onPressed: onToggleInternal,
                    icon: Icon(
                      isInternal ? Icons.lock : Icons.lock_open_outlined,
                      color: isInternal
                          ? const Color(0xFFF59E0B)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // 댓글 입력 필드
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: isInternal ? '내부 메모 입력...' : '댓글 입력...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isInternal
                        ? const Color(0xFFFFECB3)
                        : theme.colorScheme.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 전송 버튼
              isSending
                  ? const SizedBox(
                      width: 36,
                      height: 36,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: onSend,
                      icon: Icon(
                        Icons.send_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: ticket_detail_screen.dart
// 역할: 티켓 상세 화면. Firestore 실시간 구독 + 댓글 시스템 포함.
//       _TicketDetailContent: 스크롤(티켓정보+이미지+댓글) + 하단 고정(액션바+입력창).
//       _ImageGallery: 첨부 이미지 가로 스크롤 + 탭 시 전체화면 다이얼로그.
//       _CommentsSection: commentListProvider 구독, user는 내부 메모 숨김.
//       _CommentBubble: 내 댓글 우측/상대 좌측 말풍선, 내부 메모 amber 표시.
//       _ActionBar: agent→처리완료, admin→담당자배정+최종종료.
//       _CommentInputBar: 댓글 입력 + 내부 메모 토글(agent/admin) + 전송.
// 연관 파일: comment_provider.dart, ticket_provider.dart, user_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
