import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';

/// 대시보드 화면
/// 통계 카드 4개(Wrap 반응형 배치), 차트 플레이스홀더, 최근 티켓 임시 목록 표시
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 통계 카드 섹션 ──────────────────────────
          Text(
            AppStrings.dashboardTitle,
            style: AppTextStyles.pageTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLg),

          // Wrap으로 반응형 카드 배치 (화면 너비에 따라 자동 줄바꿈)
          _StatCardGrid(),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 차트 플레이스홀더 섹션 ──────────────────
          Text(
            '티켓 현황 차트',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          _ChartPlaceholder(),

          const SizedBox(height: AppSizes.paddingXl),

          // ── 최근 티켓 목록 섹션 ────────────────────
          Text(
            AppStrings.dashboardRecentTickets,
            style: AppTextStyles.sectionTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMd),
          _RecentTicketList(),
        ],
      ),
    );
  }
}

// ── 통계 카드 그리드 ──────────────────────────────────────────────────────────
/// 4개의 통계 카드를 Wrap으로 반응형 배치
class _StatCardGrid extends StatelessWidget {
  // 임시 통계 데이터 (추후 Provider에서 실제 데이터로 교체)
  static const List<_StatCardData> _stats = [
    _StatCardData(
      label: AppStrings.dashboardTotalTickets,
      value: '128',
      icon: Icons.confirmation_number_outlined,
      color: Color(0xFF1565C0),
    ),
    _StatCardData(
      label: AppStrings.dashboardPendingTickets,
      value: '34',
      icon: Icons.hourglass_empty_outlined,
      color: Color(0xFF757575),
    ),
    _StatCardData(
      label: AppStrings.dashboardInProgressTickets,
      value: '57',
      icon: Icons.sync_outlined,
      color: Color(0xFF1E88E5),
    ),
    _StatCardData(
      label: AppStrings.dashboardResolvedTickets,
      value: '37',
      icon: Icons.check_circle_outline,
      color: Color(0xFF43A047),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.paddingMd,
      runSpacing: AppSizes.paddingMd,
      children: _stats.map((data) => _StatCard(data: data)).toList(),
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
              // 아이콘 영역
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
              // 수치 / 레이블 영역
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

// ── 차트 플레이스홀더 ─────────────────────────────────────────────────────────
/// 7~8주차 fl_chart 연동 전까지 표시할 플레이스홀더
class _ChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSizes.paddingSm),
            Text(
              // 7~8주차 fl_chart 연동 예정
              AppStrings.dashboardChartPlaceholder,
              style: AppTextStyles.bodyMd.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 최근 티켓 임시 목록 ───────────────────────────────────────────────────────
/// 임시 티켓 데이터로 구성한 최근 티켓 목록
class _RecentTicketList extends StatelessWidget {
  // 임시 더미 데이터 (추후 Hive DB 연동으로 교체)
  static const List<Map<String, String>> _dummyTickets = [
    {'id': '#001', 'title': '로그인 오류 발생', 'status': '진행 중', 'priority': '높음'},
    {'id': '#002', 'title': '결제 모듈 버그 수정 요청', 'status': '대기 중', 'priority': '긴급'},
    {'id': '#003', 'title': 'UI 개선 사항 제안', 'status': '해결됨', 'priority': '낮음'},
    {'id': '#004', 'title': '서버 응답 지연 문제', 'status': '진행 중', 'priority': '중간'},
    {'id': '#005', 'title': '사용자 권한 설정 오류', 'status': '대기 중', 'priority': '높음'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dummyTickets.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ticket = _dummyTickets[index];
          return ListTile(
            leading: Text(
              ticket['id']!,
              style: AppTextStyles.badge.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              ticket['title']!,
              style: AppTextStyles.cardTitle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusChip(ticket['status']!),
                const SizedBox(width: AppSizes.paddingSm),
                _PriorityChip(ticket['priority']!),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 상태 칩 위젯
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status, style: AppTextStyles.badge),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// 우선순위 칩 위젯
class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip(this.priority);

  Color _color() {
    switch (priority) {
      case '긴급':
        return const Color(0xFFB71C1C);
      case '높음':
        return const Color(0xFFE53935);
      case '중간':
        return const Color(0xFFFB8C00);
      default:
        return const Color(0xFF43A047);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        priority,
        style: AppTextStyles.badge.copyWith(color: Colors.white),
      ),
      backgroundColor: _color(),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: dashboard_screen.dart
// 역할: 대시보드 메인 화면. 통계 카드 4개(전체/대기/진행/해결), 차트 플레이스홀더,
//       최근 티켓 더미 목록을 표시. Wrap으로 반응형 카드 배치.
// 하위 위젯: _StatCardGrid, _StatCard, _ChartPlaceholder, _RecentTicketList
