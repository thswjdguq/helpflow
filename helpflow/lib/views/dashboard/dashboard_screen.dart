import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/user_model.dart';
import '../../features/dashboard/dashboard_provider.dart';
import '../../shared/models/ticket_model.dart';
import '../../shared/widgets/skeleton_loader.dart';

/// 대시보드 화면 (역할별 분기)
///
/// admin  → 전체 현황 통계 + 바 차트 + 최근 티켓
/// agent  → 내 배정 업무 현황 + 긴급 티켓 강조 + 최근 배정 티켓
/// user   → 내 티켓 현황 + 새 티켓 접수 CTA + 최근 내 티켓
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserProvider).value?.role ?? UserRole.user;

    return switch (role) {
      UserRole.admin => const _AdminDashboard(),
      UserRole.agent => const _AgentDashboard(),
      _ => const _UserDashboard(),
    };
  }
}

// ── 관리자 대시보드 ────────────────────────────────────────────────────────────

/// admin 전용: 전체 티켓 현황 통계 + 바 차트 + 최근 티켓 목록
class _AdminDashboard extends ConsumerWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(ticketStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 페이지 제목 ──────────────────────────────────────────────
          Text(
            '관리자 대시보드',
            style: AppTextStyles.pageTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '전체 헬프데스크 현황을 한눈에 확인합니다',
            style: AppTextStyles.bodySm.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLg),

          // ── 통계 카드 ────────────────────────────────────────────────
          statsAsync.when(
            data: (stats) => _StatCardGrid(
              cards: [
                _StatCardData(
                  label: AppStrings.dashboardTotalTickets,
                  value: stats.total.toString(),
                  icon: Icons.confirmation_number_outlined,
                  color: const Color(0xFF1565C0),
                ),
                _StatCardData(
                  label: '신규 접수',
                  value: stats.newCount.toString(),
                  icon: Icons.fiber_new_outlined,
                  color: const Color(0xFF757575),
                ),
                _StatCardData(
                  label: AppStrings.dashboardInProgressTickets,
                  value: stats.inProgress.toString(),
                  icon: Icons.sync_outlined,
                  color: const Color(0xFFFB8C00),
                ),
                _StatCardData(
                  label: '긴급 티켓',
                  value: stats.critical.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: const Color(0xFFB71C1C),
                ),
              ],
            ),
            loading: () => const SkeletonStatGrid(count: 4),
            error: (err, st) => const SkeletonStatGrid(count: 4),
          ),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 티켓 상태별 바 차트 ──────────────────────────────────────
          Text(
            '티켓 현황 차트',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          const _StatusBarChart(),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 최근 접수 티켓 ───────────────────────────────────────────
          Text(
            AppStrings.dashboardRecentTickets,
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          const _RecentTicketList(useAgent: false, useUser: false),
        ],
      ),
    );
  }
}

// ── 담당자 대시보드 ───────────────────────────────────────────────────────────

/// agent 전용: 내 배정 업무 현황 + 처리 대기 티켓 강조 + 최근 배정 티켓
class _AgentDashboard extends ConsumerWidget {
  const _AgentDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(myAgentStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 페이지 제목 ──────────────────────────────────────────────
          Text(
            '내 업무 현황',
            style: AppTextStyles.pageTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '나에게 배정된 티켓을 관리합니다',
            style: AppTextStyles.bodySm.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLg),

          // ── 내 배정 통계 카드 ────────────────────────────────────────
          statsAsync.when(
            data: (stats) => _StatCardGrid(
              cards: [
                _StatCardData(
                  label: '전체 배정',
                  value: stats.total.toString(),
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF1565C0),
                ),
                _StatCardData(
                  label: '처리 중',
                  value: stats.inProgress.toString(),
                  icon: Icons.sync_outlined,
                  color: const Color(0xFFFB8C00),
                ),
                _StatCardData(
                  label: '해결 완료',
                  value: stats.resolved.toString(),
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF43A047),
                ),
                _StatCardData(
                  label: '긴급',
                  value: stats.critical.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: const Color(0xFFB71C1C),
                ),
              ],
            ),
            loading: () => const SkeletonStatGrid(count: 4),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 처리 필요 안내 배너 ──────────────────────────────────────
          _AgentActionBanner(),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 최근 배정 티켓 ───────────────────────────────────────────
          Text(
            '최근 배정된 티켓',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          const _RecentTicketList(useAgent: true, useUser: false),
        ],
      ),
    );
  }
}

/// 담당자에게 처리해야 할 티켓이 있을 때 강조 배너
class _AgentActionBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(myAgentStatsProvider);
    final stats = statsAsync.value;
    if (stats == null || stats.inProgress == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: const Color(0xFFFB8C00).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: const Color(0xFFFB8C00).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions, color: Color(0xFFFB8C00), size: 28),
          const SizedBox(width: AppSizes.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '처리 대기 중인 티켓 ${stats.inProgress}건',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: const Color(0xFFFB8C00),
                  ),
                ),
                Text(
                  '티켓 목록에서 처리 완료 버튼을 눌러 진행해주세요',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.tickets),
            child: const Text('바로가기'),
          ),
        ],
      ),
    );
  }
}

// ── 직원 대시보드 ─────────────────────────────────────────────────────────────

/// user 전용: 내 티켓 현황 요약 + 새 티켓 접수 CTA + 최근 내 티켓
class _UserDashboard extends ConsumerWidget {
  const _UserDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(myUserStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 페이지 제목 ──────────────────────────────────────────────
          Text(
            '내 티켓 현황',
            style: AppTextStyles.pageTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '접수한 티켓의 처리 현황을 확인합니다',
            style: AppTextStyles.bodySm.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLg),

          // ── 새 티켓 접수 CTA 배너 ────────────────────────────────────
          _NewTicketCtaBanner(),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 내 티켓 통계 카드 ────────────────────────────────────────
          statsAsync.when(
            data: (stats) => _StatCardGrid(
              cards: [
                _StatCardData(
                  label: '전체 접수',
                  value: stats.total.toString(),
                  icon: Icons.confirmation_number_outlined,
                  color: const Color(0xFF1565C0),
                ),
                _StatCardData(
                  label: '처리 대기',
                  value: stats.newCount.toString(),
                  icon: Icons.hourglass_empty_outlined,
                  color: const Color(0xFF757575),
                ),
                _StatCardData(
                  label: '처리 중',
                  value: stats.inProgress.toString(),
                  icon: Icons.sync_outlined,
                  color: const Color(0xFFFB8C00),
                ),
                _StatCardData(
                  label: '해결 완료',
                  value: stats.resolved.toString(),
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF43A047),
                ),
              ],
            ),
            loading: () => const SkeletonStatGrid(count: 4),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 최근 내 티켓 ─────────────────────────────────────────────
          Text(
            '최근 접수한 티켓',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          const _RecentTicketList(useAgent: false, useUser: true),
        ],
      ),
    );
  }
}

/// 직원 전용: 새 티켓 접수 유도 CTA 배너
class _NewTicketCtaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IT 문제가 발생했나요?',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '지금 바로 접수하면 담당자가 빠르게 처리해 드립니다',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.paddingMd),
          FilledButton(
            onPressed: () => context.go(AppRoutes.ticketNew),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
            ),
            child: const Text('티켓 접수'),
          ),
        ],
      ),
    );
  }
}

// ── 통계 카드 그리드 ──────────────────────────────────────────────────────────

/// 카드 데이터 목록을 받아 Wrap 반응형으로 배치
class _StatCardGrid extends StatelessWidget {
  final List<_StatCardData> cards;

  const _StatCardGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.paddingMd,
      runSpacing: AppSizes.paddingMd,
      children: cards.map((data) => _StatCard(data: data)).toList(),
    );
  }
}

/// 통계 카드 데이터 모델 (UI 전용)
class _StatCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// 개별 통계 카드 위젯
class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppSizes.statCardMinWidth,
        minHeight: AppSizes.statCardHeight,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 배경 원형
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: AppSizes.iconMd),
              ),
              const SizedBox(width: AppSizes.paddingMd),
              // 수치 + 레이블
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.value,
                    style: AppTextStyles.statNumber.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    data.label,
                    style: AppTextStyles.statLabel.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 티켓 상태별 바 차트 (admin 전용) ─────────────────────────────────────────

/// ticketStatsProvider를 구독해 상태별 티켓 수를 바 차트로 표시
class _StatusBarChart extends ConsumerWidget {
  const _StatusBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(ticketStatsProvider);

    return statsAsync.when(
      data: (stats) => _BarChartContent(stats: stats),
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// 실제 BarChart 렌더링 위젯
class _BarChartContent extends StatelessWidget {
  final TicketStats stats;

  const _BarChartContent({required this.stats});

  // 상태별 색상
  static const _colors = [
    Color(0xFF1565C0), // 신규 — 파랑
    Color(0xFFFB8C00), // 처리중 — 주황
    Color(0xFF43A047), // 해결됨 — 초록
    Color(0xFF757575), // 종료 — 회색
  ];

  static const _labels = ['신규', '처리중', '해결됨', '종료'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = [
      stats.newCount.toDouble(),
      stats.inProgress.toDouble(),
      stats.resolved.toDouble(),
      stats.closed.toDouble(),
    ];
    // Y축 최댓값: 최소 5 이상, 실제 최댓값 + 여유 1
    final maxY = (counts.reduce((a, b) => a > b ? a : b) + 1).clamp(5, 9999).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingLg,
          AppSizes.paddingLg,
          AppSizes.paddingMd,
        ),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      theme.colorScheme.inverseSurface.withValues(alpha: 0.9),
                  getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                    '${_labels[group.x]}\n${rod.toY.toInt()}건',
                    AppTextStyles.bodySm.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                // X축: 상태 레이블
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, _) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _labels[value.toInt()],
                        style: AppTextStyles.bodySm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                // Y축: 건수 (정수)
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: maxY <= 5 ? 1 : (maxY / 5).ceilToDouble(),
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: AppTextStyles.bodySm.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outlineVariant,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(4, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: counts[i],
                      color: _colors[i],
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: _colors[i].withValues(alpha: 0.07),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 최근 티켓 목록 ────────────────────────────────────────────────────────────

/// 역할에 따라 다른 Provider를 구독해 최근 티켓 표시
///
/// useAgent: true → myAgentRecentTicketsProvider (담당자 배정 티켓)
/// useUser:  true → myUserRecentTicketsProvider  (직원 접수 티켓)
/// 둘 다 false   → recentTicketsProvider          (전체 티켓, admin)
class _RecentTicketList extends ConsumerWidget {
  final bool useAgent;
  final bool useUser;

  const _RecentTicketList({
    required this.useAgent,
    required this.useUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = useAgent
        ? ref.watch(myAgentRecentTicketsProvider)
        : useUser
            ? ref.watch(myUserRecentTicketsProvider)
            : ref.watch(recentTicketsProvider);

    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXl),
              child: Text(
                useUser ? '아직 접수한 티켓이 없습니다' : '티켓이 없습니다',
                style: AppTextStyles.bodyMd.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _RecentTicketTile(ticket: tickets[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// 최근 티켓 목록의 개별 항목 타일
class _RecentTicketTile extends StatelessWidget {
  final TicketModel ticket;

  const _RecentTicketTile({required this.ticket});

  /// 상태 코드 → 색상
  Color _statusColor(String status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.go('/tickets/${ticket.id}'),
      title: Text(
        ticket.title,
        style: AppTextStyles.cardTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        TicketCategory.label(ticket.category),
        style: AppTextStyles.bodySm.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상태 배지
          _MiniChip(
            label: TicketStatus.label(ticket.status),
            color: _statusColor(ticket.status),
          ),
          const SizedBox(width: AppSizes.paddingXs),
          // 우선순위 배지
          _MiniChip(
            label: TicketPriority.label(ticket.priority),
            color: _priorityColor(ticket.priority),
          ),
        ],
      ),
    );
  }
}

/// 작은 색상 배지 칩
class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: dashboard_screen.dart
// 역할: 역할별 대시보드 화면. role에 따라 세 가지 레이아웃으로 분기.
//       _AdminDashboard: 전체 통계 카드 + 바 차트 + 최근 전체 티켓.
//       _AgentDashboard: 내 배정 통계 카드 + 처리 대기 배너 + 최근 배정 티켓.
//       _UserDashboard:  내 접수 통계 카드 + 새 티켓 접수 CTA + 최근 내 티켓.
//       _StatCardGrid: 통계 카드 Wrap 배치.
//       _StatusBarChart: fl_chart BarChart (admin 전용).
//       _RecentTicketList: 역할에 따라 Provider 선택해 최근 티켓 표시.
// 연관 파일: dashboard_provider.dart, ticket_model.dart, auth_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
