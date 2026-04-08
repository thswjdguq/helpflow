import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/dashboard/dashboard_provider.dart';
import '../../shared/models/ticket_model.dart';

/// 대시보드 화면
///
/// Firestore 실시간 데이터 기반 통계 카드 4개 + 최근 티켓 목록 표시.
/// ticketStatsProvider: 전체/신규/처리중/해결됨/긴급 카운트 실시간 집계.
/// recentTicketsProvider: 최근 5개 티켓 실시간 표시.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 실시간 통계 구독
    final statsAsync = ref.watch(ticketStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 페이지 제목 ──────────────────────────────────────────────
          Text(
            AppStrings.dashboardTitle,
            style: AppTextStyles.pageTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLg),

          // ── 통계 카드 (실데이터) ─────────────────────────────────────
          statsAsync.when(
            data: (stats) => _StatCardGrid(stats: stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _StatCardGrid(stats: const TicketStats.empty()),
          ),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 티켓 상태별 바 차트 (fl_chart) ──────────────────────────
          Text(
            '티켓 현황 차트',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          const _StatusBarChart(),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 최근 티켓 목록 (실데이터) ────────────────────────────────
          Text(
            AppStrings.dashboardRecentTickets,
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          const _RecentTicketList(),
        ],
      ),
    );
  }
}

// ── 통계 카드 그리드 ──────────────────────────────────────────────────────────

/// 실시간 TicketStats로 통계 카드 4개를 Wrap 반응형 배치
class _StatCardGrid extends StatelessWidget {
  final TicketStats stats;

  const _StatCardGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    // stats 값을 카드 데이터로 변환
    final cards = [
      _StatCardData(
        label: AppStrings.dashboardTotalTickets,
        value: stats.total.toString(),
        icon: Icons.confirmation_number_outlined,
        color: const Color(0xFF1565C0),
      ),
      _StatCardData(
        label: AppStrings.dashboardPendingTickets,
        value: stats.newCount.toString(),
        icon: Icons.hourglass_empty_outlined,
        color: const Color(0xFF757575),
      ),
      _StatCardData(
        label: AppStrings.dashboardInProgressTickets,
        value: stats.inProgress.toString(),
        icon: Icons.sync_outlined,
        color: const Color(0xFF1E88E5),
      ),
      _StatCardData(
        label: AppStrings.dashboardResolvedTickets,
        value: stats.resolved.toString(),
        icon: Icons.check_circle_outline,
        color: const Color(0xFF43A047),
      ),
    ];

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

// ── 티켓 상태별 바 차트 ───────────────────────────────────────────────────────

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

// ── 최근 티켓 목록 (실데이터) ─────────────────────────────────────────────────

/// recentTicketsProvider를 구독해 최근 5개 티켓을 실시간으로 표시
class _RecentTicketList extends ConsumerWidget {
  const _RecentTicketList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(recentTicketsProvider);

    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Text(
              '아직 티켓이 없습니다',
              style: AppTextStyles.bodyMd.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
// 역할: 대시보드 메인 화면. Firestore 실시간 통계 및 최근 티켓 표시.
//       _StatCardGrid: ticketStatsProvider로 전체/신규/처리중/해결됨 카드.
//       _StatusBarChart: fl_chart BarChart — 상태별(신규/처리중/해결됨/종료) 건수 시각화.
//       _RecentTicketList: recentTicketsProvider로 최근 5개 티켓 목록.
//       최근 티켓 타일 클릭 시 /tickets/:id 상세 화면으로 이동.
// 연관 파일: dashboard_provider.dart, ticket_model.dart
// ─────────────────────────────────────────────────────────────────────────────
