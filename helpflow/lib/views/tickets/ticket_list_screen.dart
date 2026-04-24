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
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/skeleton_loader.dart';

/// 티켓 목록 화면
///
/// 역할에 따라 다른 데이터 구독:
///   admin → ticketListStreamProvider (전체 티켓, 관리 목적)
///   agent → myAssignedTicketListProvider (내 배정 티켓만)
///   user  → myTicketListStreamProvider (내 접수 티켓만)
/// 상단 필터 바(상태별)로 클라이언트 사이드 필터링 지원
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  /// 선택된 상태 필터 (null = 전체)
  String? _statusFilter;

  /// 검색 키워드 (빈 문자열 = 전체)
  String _searchQuery = '';

  /// 검색 입력 컨트롤러
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 현재 사용자 역할 조회 (로딩 중이면 기본 user로 처리)
    final role = ref.watch(currentUserProvider).value?.role ?? UserRole.user;

    // 역할에 따라 Stream Provider 선택
    final ticketsAsync = switch (role) {
      UserRole.admin => ref.watch(ticketListStreamProvider),
      UserRole.agent => ref.watch(myAssignedTicketListProvider),
      _ => ref.watch(myTicketListStreamProvider),
    };

    // 빈 상태 메시지를 역할별로 다르게 표시
    final emptyMessage = switch (role) {
      UserRole.admin => '접수된 티켓이 없습니다',
      UserRole.agent => '배정된 티켓이 없습니다',
      _ => AppStrings.emptyTickets,
    };
    final emptySubtitle = switch (role) {
      UserRole.admin => '아직 접수된 티켓이 없습니다',
      UserRole.agent => '아직 담당자로 배정된 티켓이 없습니다',
      _ => AppStrings.emptyTicketsSubtitle,
    };

    final hasActiveFilter = _statusFilter != null || _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── user 전용: 상단 새 티켓 접수 버튼 헤더 ──────────────────
          if (role == UserRole.user) _UserTicketHeader(),

          // ── 검색 바 (모든 역할) ───────────────────────────────────────
          _SearchBar(
            controller: _searchController,
            onChanged: (q) => setState(() => _searchQuery = q),
          ),

          // ── 상태 필터 바 (모든 역할) ──────────────────────────────────
          _StatusFilterBar(
            selected: _statusFilter,
            onSelect: (v) => setState(() => _statusFilter = v),
          ),

          // ── 티켓 목록 ─────────────────────────────────────────────────
          Expanded(
            child: ticketsAsync.when(
              // ── 데이터 로드 완료 ───────────────────────────────────────
              data: (allTickets) {
                // 상태 필터 적용
                var tickets = _statusFilter == null
                    ? allTickets
                    : allTickets.where((t) => t.status == _statusFilter).toList();

                // 검색어 필터 적용 (제목 + 설명 대소문자 무시)
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  tickets = tickets.where((t) {
                    return t.title.toLowerCase().contains(q) ||
                        t.description.toLowerCase().contains(q) ||
                        t.reporterName.toLowerCase().contains(q);
                  }).toList();
                }

                if (tickets.isEmpty) {
                  return EmptyStateWidget(
                    icon: hasActiveFilter
                        ? Icons.search_off_outlined
                        : Icons.confirmation_number_outlined,
                    message: hasActiveFilter
                        ? '검색 결과가 없습니다'
                        : emptyMessage,
                    subtitle: hasActiveFilter
                        ? '검색어나 필터를 변경해보세요'
                        : emptySubtitle,
                    action: role == UserRole.user && !hasActiveFilter
                        ? FilledButton.icon(
                            onPressed: () => context.go(AppRoutes.ticketNew),
                            icon: const Icon(Icons.add),
                            label: const Text(AppStrings.btnNewTicket),
                          )
                        : null,
                  );
                }

                // pull-to-refresh: 스트림 Provider를 invalidate해 재구독
                return RefreshIndicator(
                  onRefresh: () async {
                    switch (role) {
                      case UserRole.admin:
                        ref.invalidate(ticketListStreamProvider);
                      case UserRole.agent:
                        ref.invalidate(myAssignedTicketListProvider);
                      default:
                        ref.invalidate(myTicketListStreamProvider);
                    }
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.paddingLg),
                    itemCount: tickets.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSizes.paddingSm),
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return _TicketCard(
                        ticket: ticket,
                        showReporter: role == UserRole.admin,
                        searchQuery: _searchQuery,
                        onTap: () => context.go('/tickets/${ticket.id}'),
                      );
                    },
                  ),
                );
              },
              // ── 로딩 중 ──────────────────────────────────────
              loading: () => const SkeletonTicketList(count: 5),
              // ── 에러 ────────────────────────────────────────────────
              error: (e, _) => ErrorView(
                message: e.toString().replaceFirst('Exception: ', ''),
                onRetry: () {
                  switch (role) {
                    case UserRole.admin:
                      ref.invalidate(ticketListStreamProvider);
                    case UserRole.agent:
                      ref.invalidate(myAssignedTicketListProvider);
                    default:
                      ref.invalidate(myTicketListStreamProvider);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 검색 바 ──────────────────────────────────────────────────────────────────

/// 키워드 검색 입력 필드 (제목·설명·접수자 대상)
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMd,
        AppSizes.paddingSm,
        AppSizes.paddingMd,
        AppSizes.paddingXs,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '티켓 제목, 내용, 접수자로 검색',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: AppSizes.paddingSm,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

// ── 상태 필터 바 ──────────────────────────────────────────────────────────────

/// 상태별 필터 칩 가로 스크롤 바
/// null 선택 시 전체, 특정 상태 선택 시 해당 상태만 표시
class _StatusFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _StatusFilterBar({required this.selected, required this.onSelect});

  static const _filters = [
    (label: '전체', value: null),
    (label: '신규', value: TicketStatus.newTicket),
    (label: '처리 중', value: TicketStatus.inProgress),
    (label: '해결 완료', value: TicketStatus.resolved),
    (label: '종료', value: TicketStatus.closed),
  ];

  static const _filterColors = {
    TicketStatus.newTicket: Color(0xFF1565C0),
    TicketStatus.inProgress: Color(0xFFFB8C00),
    TicketStatus.resolved: Color(0xFF43A047),
    TicketStatus.closed: Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final isSelected = selected == f.value;
            final chipColor = f.value != null
                ? _filterColors[f.value]!
                : theme.colorScheme.primary;

            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingSm),
              child: FilterChip(
                label: Text(f.label),
                selected: isSelected,
                onSelected: (_) => onSelect(f.value),
                selectedColor: chipColor.withValues(alpha: 0.15),
                checkmarkColor: chipColor,
                labelStyle: AppTextStyles.bodySm.copyWith(
                  color: isSelected
                      ? chipColor
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isSelected
                      ? chipColor
                      : theme.colorScheme.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── 직원 전용 상단 헤더 ───────────────────────────────────────────────────────

/// user 전용: 티켓 목록 상단에 새 티켓 접수 버튼을 표시하는 헤더
class _UserTicketHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingMd,
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내 티켓 목록',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '접수한 티켓의 처리 현황을 확인합니다',
                  style: AppTextStyles.bodySm.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.ticketNew),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('새 티켓'),
          ),
        ],
      ),
    );
  }
}

// ── 티켓 카드 ────────────────────────────────────────────────────────────────

/// 개별 티켓을 카드 형태로 표시
/// 상태 배지, 우선순위 배지, 제목, 설명(최대 2줄), 카테고리, 날짜 포함
/// showReporter: true이면 접수자 이름 표시 (admin 전용)
/// searchQuery: 비어있지 않으면 제목에서 일치 부분을 강조 표시
class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final bool showReporter;
  final String searchQuery;

  const _TicketCard({
    required this.ticket,
    required this.onTap,
    this.showReporter = false,
    this.searchQuery = '',
  });

  /// 검색어가 포함된 텍스트를 RichText로 강조 표시
  Widget _highlightedText(
    String text,
    String query,
    TextStyle baseStyle,
    TextStyle highlightStyle, {
    int? maxLines,
  }) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle, maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }
    final lower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lower.indexOf(queryLower, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(TextSpan(
          text: text.substring(idx, idx + query.length),
          style: highlightStyle));
      start = idx + query.length;
    }
    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }

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

              // ── 제목 (검색어 일치 시 하이라이트) ─────────────────────
              _highlightedText(
                ticket.title,
                searchQuery,
                AppTextStyles.cardTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                AppTextStyles.cardTitle.copyWith(
                  color: theme.colorScheme.primary,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                maxLines: 2,
              ),

              // ── 설명 (있는 경우만, 검색어 하이라이트) ─────────────────
              if (ticket.description.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingXs),
                _highlightedText(
                  ticket.description,
                  searchQuery,
                  AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  AppTextStyles.bodyMd.copyWith(
                    color: theme.colorScheme.primary,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: AppSizes.paddingSm),

              // ── 카테고리 + 접수자 (admin 전용) ───────────────────────
              Row(
                children: [
                  Text(
                    TicketCategory.label(ticket.category),
                    style: AppTextStyles.bodySm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (showReporter && ticket.agentId != null) ...[
                    const SizedBox(width: AppSizes.paddingSm),
                    Icon(
                      Icons.person_outline,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '담당자 배정됨',
                      style: AppTextStyles.bodySm.copyWith(
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                  if (showReporter && ticket.agentId == null) ...[
                    const SizedBox(width: AppSizes.paddingSm),
                    Text(
                      '미배정',
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
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
// 역할: 역할별 티켓 목록 화면.
//       admin → ticketListStreamProvider (전체 티켓, 배정 여부 표시).
//       agent → myAssignedTicketListProvider (내 배정 티켓만).
//       user  → myTicketListStreamProvider (내 접수 티켓) + 상단 CTA 헤더.
//       빈 상태: EmptyStateWidget + 역할별 메시지.
//       _TicketCard: 상태·우선순위 배지, 제목, 설명, 카테고리, 날짜, 배정 상태.
//       _UserTicketHeader: 직원 전용 상단 새 티켓 접수 버튼 헤더.
// 연관 파일: ticket_provider.dart, ticket_model.dart, auth_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
