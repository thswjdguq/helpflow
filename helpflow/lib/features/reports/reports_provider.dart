import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/ticket_model.dart';
import '../tickets/ticket_provider.dart';

// ── 리포트 데이터 모델 ─────────────────────────────────────────────────────────

/// 티켓 통계 리포트에 필요한 집계 데이터 모음
class TicketReportData {
  /// 전체 티켓 수
  final int total;

  /// 상태별 카운트
  final int newCount;
  final int inProgress;
  final int resolved;
  final int closed;

  /// 긴급(critical) 우선순위 티켓 수
  final int critical;

  /// 미처리 티켓 수 (new + in_progress)
  final int pending;

  /// 해결률 (%) = (resolved + closed) / total × 100
  final double resolvedRate;

  /// 카테고리별 티켓 수 (key: 카테고리 코드, value: 건수)
  final Map<String, int> byCategory;

  /// 우선순위별 티켓 수 (key: 우선순위 코드, value: 건수)
  final Map<String, int> byPriority;

  /// 최근 14일 일별 신규 접수 수 (순서 보장 리스트, "MM/DD" → count)
  final List<MapEntry<String, int>> dailyCreated;

  const TicketReportData({
    required this.total,
    required this.newCount,
    required this.inProgress,
    required this.resolved,
    required this.closed,
    required this.critical,
    required this.pending,
    required this.resolvedRate,
    required this.byCategory,
    required this.byPriority,
    required this.dailyCreated,
  });

  /// 빈 데이터 (티켓 0건 상태)
  static const empty = TicketReportData(
    total: 0,
    newCount: 0,
    inProgress: 0,
    resolved: 0,
    closed: 0,
    critical: 0,
    pending: 0,
    resolvedRate: 0.0,
    byCategory: {},
    byPriority: {},
    dailyCreated: [],
  );
}

// ── 리포트 Provider ────────────────────────────────────────────────────────────

/// 전체 티켓 스트림에서 통계 데이터를 집계하는 Provider
///
/// ticketListStreamProvider를 watch하므로 Firestore 변경 시 자동으로 갱신됨
final reportDataProvider = Provider<AsyncValue<TicketReportData>>((ref) {
  final ticketsAsync = ref.watch(ticketListStreamProvider);

  return ticketsAsync.whenData((tickets) {
    if (tickets.isEmpty) return TicketReportData.empty;

    // ── 상태별 집계 ─────────────────────────────────────────────────────────
    final newCount = tickets
        .where((t) => t.status == TicketStatus.newTicket)
        .length;
    final inProgress = tickets
        .where((t) => t.status == TicketStatus.inProgress)
        .length;
    final resolved = tickets
        .where((t) => t.status == TicketStatus.resolved)
        .length;
    final closed = tickets
        .where((t) => t.status == TicketStatus.closed)
        .length;
    final critical = tickets
        .where((t) => t.priority == TicketPriority.critical)
        .length;
    final pending = newCount + inProgress;
    final total = tickets.length;
    final resolvedRate = (resolved + closed) / total * 100;

    // ── 카테고리별 집계 ─────────────────────────────────────────────────────
    // 순서 고정: hardware → software → network → etc
    final byCategory = <String, int>{
      TicketCategory.hardware: 0,
      TicketCategory.software: 0,
      TicketCategory.network: 0,
      TicketCategory.etc: 0,
    };
    for (final t in tickets) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + 1;
    }

    // ── 우선순위별 집계 ─────────────────────────────────────────────────────
    // 순서 고정: critical → high → medium → low
    final byPriority = <String, int>{
      TicketPriority.critical: 0,
      TicketPriority.high: 0,
      TicketPriority.medium: 0,
      TicketPriority.low: 0,
    };
    for (final t in tickets) {
      byPriority[t.priority] = (byPriority[t.priority] ?? 0) + 1;
    }

    // ── 최근 14일 일별 신규 접수 수 ─────────────────────────────────────────
    final now = DateTime.now();
    // 날짜 → 건수 맵 (날짜 순서 보장)
    final dateMap = <String, int>{};
    for (var i = 13; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key =
          '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
      dateMap[key] = 0;
    }
    for (final t in tickets) {
      final diff = now.difference(t.createdAt);
      if (diff.inDays < 14) {
        final d = t.createdAt;
        final key =
            '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
        if (dateMap.containsKey(key)) {
          dateMap[key] = dateMap[key]! + 1;
        }
      }
    }

    return TicketReportData(
      total: total,
      newCount: newCount,
      inProgress: inProgress,
      resolved: resolved,
      closed: closed,
      critical: critical,
      pending: pending,
      resolvedRate: resolvedRate,
      byCategory: Map.unmodifiable(byCategory),
      byPriority: Map.unmodifiable(byPriority),
      dailyCreated: dateMap.entries.toList(),
    );
  });
});

// ── [파일 요약] ───────────────────────────────────────────────────────────────
// 파일명: reports_provider.dart
// 역할: 전체 티켓 데이터에서 통계 리포트용 집계 데이터를 계산하는 Provider.
//       TicketReportData: 상태별/카테고리별/우선순위별 건수, 최근 14일 일별 추이.
//       reportDataProvider: ticketListStreamProvider를 구독해 실시간 갱신.
// 연관 파일: ticket_provider.dart, ticket_model.dart
// ─────────────────────────────────────────────────────────────────────────────
