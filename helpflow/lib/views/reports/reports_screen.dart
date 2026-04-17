import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/reports/reports_provider.dart';
import '../../shared/models/ticket_model.dart';

/// 통계 리포트 화면 (admin 전용)
///
/// 전체 티켓 데이터를 집계해 아래 섹션으로 구성:
///  1. 요약 카드 4개 (전체 / 해결률 / 긴급 / 미처리)
///  2. 상태별 막대 차트
///  3. 일별 접수 현황 꺾은선 차트 (최근 14일)
///  4. 카테고리별 + 우선순위별 막대 차트 (반응형 2열/1열)
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: reportAsync.when(
        data: (data) => _ReportBody(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('오류가 발생했습니다: $e',
              style: AppTextStyles.bodyMd),
        ),
      ),
    );
  }
}

// ── 리포트 본문 ──────────────────────────────────────────────────────────────

class _ReportBody extends StatelessWidget {
  final TicketReportData data;
  const _ReportBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppSizes.breakpointTablet;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 헤더 ────────────────────────────────────────────────────────
          Text(
            '통계 리포트',
            style: AppTextStyles.pageTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '전체 헬프데스크 티켓 현황을 분석합니다',
            style: AppTextStyles.bodySm.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLg),

          // ── 요약 카드 ────────────────────────────────────────────────────
          _SummaryCardGrid(data: data),
          const SizedBox(height: AppSizes.paddingXl),

          // ── 상태별 분포 ──────────────────────────────────────────────────
          _SectionTitle(title: '상태별 분포'),
          const SizedBox(height: AppSizes.paddingMd),
          _StatusBarChart(data: data),
          const SizedBox(height: AppSizes.paddingXl),

          // ── 일별 접수 현황 ───────────────────────────────────────────────
          _SectionTitle(title: '일별 접수 현황 (최근 14일)'),
          const SizedBox(height: AppSizes.paddingMd),
          _DailyLineChart(entries: data.dailyCreated),
          const SizedBox(height: AppSizes.paddingXl),

          // ── 카테고리 + 우선순위 (넓은 화면: 2열, 좁은 화면: 1열) ─────────
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: '카테고리별 현황'),
                      const SizedBox(height: AppSizes.paddingMd),
                      _CategoryBarChart(data: data),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.paddingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: '우선순위별 현황'),
                      const SizedBox(height: AppSizes.paddingMd),
                      _PriorityBarChart(data: data),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _SectionTitle(title: '카테고리별 현황'),
            const SizedBox(height: AppSizes.paddingMd),
            _CategoryBarChart(data: data),
            const SizedBox(height: AppSizes.paddingXl),
            _SectionTitle(title: '우선순위별 현황'),
            const SizedBox(height: AppSizes.paddingMd),
            _PriorityBarChart(data: data),
          ],
          const SizedBox(height: AppSizes.paddingLg),
        ],
      ),
    );
  }
}

// ── 섹션 타이틀 ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ── 요약 카드 그리드 ─────────────────────────────────────────────────────────

class _SummaryCardGrid extends StatelessWidget {
  final TicketReportData data;
  const _SummaryCardGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final resolvedText =
        data.total > 0 ? '${data.resolvedRate.toStringAsFixed(1)}%' : '-';

    return LayoutBuilder(
      builder: (context, constraints) {
        // 태블릿 이상에서는 4열, 모바일에서는 2열
        final crossCount = constraints.maxWidth >= 600 ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - (crossCount - 1) * AppSizes.paddingMd) /
                crossCount;

        return Wrap(
          spacing: AppSizes.paddingMd,
          runSpacing: AppSizes.paddingMd,
          children: [
            SizedBox(
              width: itemWidth,
              child: _SummaryCard(
                label: '전체 티켓',
                value: data.total.toString(),
                icon: Icons.confirmation_number_outlined,
                color: const Color(0xFF1565C0),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryCard(
                label: '해결률',
                value: resolvedText,
                icon: Icons.check_circle_outline,
                color: const Color(0xFF2E7D32),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryCard(
                label: '긴급 티켓',
                value: data.critical.toString(),
                icon: Icons.warning_amber_outlined,
                color: const Color(0xFFB71C1C),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _SummaryCard(
                label: '미처리',
                value: data.pending.toString(),
                icon: Icons.pending_outlined,
                color: const Color(0xFFFB8C00),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 요약 통계 카드 위젯
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: AppSizes.paddingSm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodySm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSm),
            Text(
              value,
              style: AppTextStyles.pageTitle.copyWith(
                color: color,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 상태별 막대 차트 ─────────────────────────────────────────────────────────

/// 신규 / 처리 중 / 해결 완료 / 종료 상태별 막대 차트
class _StatusBarChart extends StatelessWidget {
  final TicketReportData data;
  const _StatusBarChart({required this.data});

  static const _colors = [
    Color(0xFF757575), // new
    Color(0xFFFB8C00), // in_progress
    Color(0xFF2E7D32), // resolved
    Color(0xFF1565C0), // closed
  ];

  static const _labels = ['신규', '처리 중', '해결 완료', '종료'];

  @override
  Widget build(BuildContext context) {
    final counts = [
      data.newCount.toDouble(),
      data.inProgress.toDouble(),
      data.resolved.toDouble(),
      data.closed.toDouble(),
    ];
    final maxY = counts.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingLg,
          AppSizes.paddingMd,
          AppSizes.paddingMd,
        ),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY < 1 ? 5 : (maxY * 1.3).ceilToDouble(),
              barGroups: List.generate(
                4,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: counts[i],
                      color: _colors[i],
                      width: 28,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= _labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _labels[idx],
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      if (value != value.floorToDouble()) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
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
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${_labels[group.x]}\n${rod.toY.toInt()}건',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 일별 접수 꺾은선 차트 ────────────────────────────────────────────────────

/// 최근 14일간 신규 티켓 접수 수 꺾은선 차트
class _DailyLineChart extends StatelessWidget {
  final List<MapEntry<String, int>> entries;
  const _DailyLineChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 200,
          child: Center(child: Text('데이터가 없습니다')),
        ),
      );
    }

    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    final maxY = entries
        .map((e) => e.value)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    // X축: 짝수 인덱스만 날짜 표시 (7개)
    final xLabels = entries.asMap().map(
          (i, e) => MapEntry(i, i % 2 == 0 ? e.key : ''),
        );

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingLg,
          AppSizes.paddingMd,
          AppSizes.paddingMd,
        ),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY < 1 ? 5 : (maxY * 1.3).ceilToDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: primaryColor,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: primaryColor,
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: primaryColor.withValues(alpha: 0.08),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      final label = xLabels[idx] ?? '';
                      if (label.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(label,
                            style: const TextStyle(fontSize: 9)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      if (value != value.floorToDouble()) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
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
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final idx = spot.x.toInt();
                      final label =
                          idx < entries.length ? entries[idx].key : '';
                      return LineTooltipItem(
                        '$label\n${spot.y.toInt()}건',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 카테고리별 막대 차트 ─────────────────────────────────────────────────────

/// hardware / software / network / etc 카테고리별 막대 차트
class _CategoryBarChart extends StatelessWidget {
  final TicketReportData data;
  const _CategoryBarChart({required this.data});

  static const _colors = [
    Color(0xFF1565C0), // hardware
    Color(0xFF6A1B9A), // software
    Color(0xFF00695C), // network
    Color(0xFF757575), // etc
  ];

  @override
  Widget build(BuildContext context) {
    final keys = [
      TicketCategory.hardware,
      TicketCategory.software,
      TicketCategory.network,
      TicketCategory.etc,
    ];
    final labels = keys.map(TicketCategory.label).toList();
    final counts =
        keys.map((k) => (data.byCategory[k] ?? 0).toDouble()).toList();
    final maxY = counts.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingLg,
          AppSizes.paddingMd,
          AppSizes.paddingMd,
        ),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY < 1 ? 5 : (maxY * 1.3).ceilToDouble(),
              barGroups: List.generate(
                keys.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: counts[i],
                      color: _colors[i],
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(labels[idx],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      if (value != value.floorToDouble()) {
                        return const SizedBox.shrink();
                      }
                      return Text(value.toInt().toString(),
                          style: const TextStyle(fontSize: 10));
                    },
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
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${labels[group.x]}\n${rod.toY.toInt()}건',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 우선순위별 막대 차트 ─────────────────────────────────────────────────────

/// critical / high / medium / low 우선순위별 막대 차트
class _PriorityBarChart extends StatelessWidget {
  final TicketReportData data;
  const _PriorityBarChart({required this.data});

  static const _colors = [
    Color(0xFFB71C1C), // critical
    Color(0xFFE65100), // high
    Color(0xFFFB8C00), // medium
    Color(0xFF43A047), // low
  ];

  @override
  Widget build(BuildContext context) {
    final keys = [
      TicketPriority.critical,
      TicketPriority.high,
      TicketPriority.medium,
      TicketPriority.low,
    ];
    final labels = keys.map(TicketPriority.label).toList();
    final counts =
        keys.map((k) => (data.byPriority[k] ?? 0).toDouble()).toList();
    final maxY = counts.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingLg,
          AppSizes.paddingMd,
          AppSizes.paddingMd,
        ),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY < 1 ? 5 : (maxY * 1.3).ceilToDouble(),
              barGroups: List.generate(
                keys.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: counts[i],
                      color: _colors[i],
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(labels[idx],
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      if (value != value.floorToDouble()) {
                        return const SizedBox.shrink();
                      }
                      return Text(value.toInt().toString(),
                          style: const TextStyle(fontSize: 10));
                    },
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
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${labels[group.x]}\n${rod.toY.toInt()}건',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: reports_screen.dart
// 역할: admin 전용 티켓 통계 리포트 화면.
//       _SummaryCardGrid: 전체/해결률/긴급/미처리 요약 카드 4개.
//       _StatusBarChart: 상태별(신규/처리중/해결완료/종료) 막대 차트.
//       _DailyLineChart: 최근 14일 일별 접수 꺾은선 차트.
//       _CategoryBarChart: 카테고리별 막대 차트.
//       _PriorityBarChart: 우선순위별 막대 차트.
//       반응형: 태블릿 이상에서 카테고리/우선순위 차트 2열 배치.
// 연관 파일: reports_provider.dart, ticket_model.dart
// ─────────────────────────────────────────────────────────────────────────────
